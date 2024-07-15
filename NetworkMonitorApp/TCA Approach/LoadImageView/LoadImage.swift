//
//  LoadImage.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 12/7/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

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


public struct LoadImageReducer: Reducer {
    private enum Constants {
        static let imageUrl = "https://fastly.picsum.photos/id/4/5000/3333.jpg?hmac=ghf06FdmgiD0-G4c9DdNM8RnBIN7BO0-ZGEw47khHP4"
    }
    
    public struct State: Equatable {
        public var networkState: NetworkState<LoadedImage, LoadImageReducer.Error>
        
        public init(networkState: NetworkState<LoadedImage, LoadImageReducer.Error>) {
            self.networkState = networkState
        }
    }
    
    public enum Action: Equatable {
        case didReceiveImage(LoadedImage)
        case didReceiveError(Error)
        case onAppear
    }
    
    private let imageRequest = ImageRequest()
    
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
                return self.loadEffect()
            }
        }
    }
}

extension LoadImageReducer {
    fileprivate func loadEffect() -> Effect<LoadImageReducer.Action> {
        return .run { send in
            let result = await imageRequest.getImageFrom(urlString: Constants.imageUrl)
            switch result {
            case .success(let image):
                let loadedImage = LoadedImage(image: image)
                return await send(.didReceiveImage(loadedImage))
            case .failure(let error):
                return await send(.didReceiveError(.cannotLoadImage(error: error.localizedDescription)))
            }
        } catch: { error, send in
            return await send(.didReceiveError(.cannotLoadImage(error: error.localizedDescription)))
        }
    }
}

// MARK: Errors

extension LoadImageReducer {
    public enum Error: Swift.Error, Equatable {
        case cannotLoadImage(error: String)
    }
}
