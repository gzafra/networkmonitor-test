//
//  LoadImage.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 12/7/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI
import Combine

public struct LoadedImage: Equatable, Identifiable, Hashable {
    
    public static func == (lhs: LoadedImage, rhs: LoadedImage) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public let id: String
    public let imageData: Data
    
    public init(id: String, imageData: Data) {
        self.id = id
        self.imageData = imageData
    }
}

public class LoadImageReducer: Reducer {
    
    public struct State: Equatable {
        public var networkState: NetworkState<LoadedImage, LoadImageReducer.ReducerError>
        public var isInternetConnected: Bool = true
        
        public init(networkState: NetworkState<LoadedImage, LoadImageReducer.ReducerError>) {
            self.networkState = networkState
        }
    }
    
    public enum Action: Equatable {
        case didReceiveImage(LoadedImage)
        case didReceiveError(ReducerError)
        case onAppear
        case internetStatusChanged(Bool)
    }
    
    internal init(
        networkMonitor: any NetworkMonitorProtocol,
        fetchImageUseCase: FetchImageUseCaseProtocol
    ) {
        self.networkMonitor = networkMonitor
        self.fetchImageUseCase = fetchImageUseCase
    }
    
    private let operationPerformer = NetworkOperationPerformer<Result<ImageDataModel, Error>>()
    private let fetchImageUseCase: FetchImageUseCaseProtocol
    private let networkMonitor: any NetworkMonitorProtocol
    private var cancellables = Set<AnyCancellable>()
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didReceiveImage(let image):
                state.networkState = .completed(.success(image))
                return .none
                
            case .didReceiveError(let error):
                state.networkState = .completed(.failure(error))
                return .none
                
            case .onAppear:
                guard case .ready = state.networkState else {
                    return .none
                }
                
                state.networkState = .loading
                return .merge(
                    self.loadEffect(), 
                    self.monitorConnectionEffect()
                )
                
            case let .internetStatusChanged(isConnected):
                state.isInternetConnected = isConnected
                return .none
            }
        }
    }
}

// MARK: - Effects

extension LoadImageReducer {
    fileprivate func loadEffect() -> Effect<LoadImageReducer.Action> {
        return Effect.run { send in
            let result = await self.fetchImage()

            switch result {
            case .success(let model):
                let loadedImage = LoadedImage(id: model.url, imageData: model.data)
                return await send(.didReceiveImage(loadedImage))
            case .failure(let error): // TODO: Handle error?
                return await send(.didReceiveError(ReducerError.cannotLoadImage(error: error.localizedDescription)))
            }
        } catch: { error, send in
            return await send(.didReceiveError(ReducerError.cannotLoadImage(error: error.localizedDescription)))
        }
    }
    
    fileprivate func monitorConnectionEffect() -> Effect<LoadImageReducer.Action> {
        return Effect.run { send in
            return self.networkMonitor.isConnectedPublisher.sink { isConnected in
                Task {
                    await send(.internetStatusChanged(isConnected))
                }
            }
            .store(in: &self.cancellables)
        }
    }
    
    private func fetchImage() async -> Result<ImageDataModel, Error> {
        let result: Result<ImageDataModel, Error>? = await operationPerformer.perform(withinSeconds: 3) {
            return await self.fetchImageUseCase.getImage()
        }
        return result ?? .failure(ReducerError.cannotLoadImage(error: "Generic Error"))
    }
}

// MARK: Errors

extension LoadImageReducer {
    public enum ReducerError: Error, Equatable {
        case cannotLoadImage(error: String)
    }
}
