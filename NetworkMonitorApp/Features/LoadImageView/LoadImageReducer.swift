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
    
    public let id = UUID()
    let image: Image
}

public class LoadImageReducer: Reducer {
    private enum Constants {
        static let imageUrl = "https://fastly.picsum.photos/id/4/5000/3333.jpg?hmac=ghf06FdmgiD0-G4c9DdNM8RnBIN7BO0-ZGEw47khHP4"
    }
    
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
    
    private let operationPerformer = NetworkOperationPerformer<Result<Image, Error>>()
    private let imageTask = ImageRequest()
    private let networkMonitor = MockNetworkMonitor(initiallyConnected: true, becomesConnected: false, after: 1) // Mock just for testing purposes
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
                return .merge(self.loadEffect(), self.monitorConnectionEfect())
                
            case let .internetStatusChanged(isConnected):
                state.isInternetConnected = isConnected
                return .none
            }
        }
    }
}

extension LoadImageReducer {
    fileprivate func loadEffect() -> Effect<LoadImageReducer.Action> {
        return .run { send in
            let result = await self.fetchImage()

            switch result {
            case .success(let image):
                let loadedImage = LoadedImage(image: image)
                return await send(.didReceiveImage(loadedImage))
            case .failure(let error): // TODO: Handle error?
                return await send(.didReceiveError(ReducerError.cannotLoadImage(error: error.localizedDescription)))
            }
        } catch: { error, send in
            return await send(.didReceiveError(ReducerError.cannotLoadImage(error: error.localizedDescription)))
        }
    }
    
    fileprivate func monitorConnectionEfect() -> Effect<LoadImageReducer.Action> {
        return Effect.run { send in
            return self.networkMonitor.isConnectedPublisher.sink { isConnected in
                Task {
                    await send(.internetStatusChanged(isConnected))
                }
            }
            .store(in: &self.cancellables)
        }
    }
    
    private func fetchImage() async -> Result<Image, Error> {
        let result: Result<Image, Error>? = await operationPerformer.perform(withinSeconds: 3) {
            return await self.imageTask.getImageFrom(urlString: Constants.imageUrl)
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
