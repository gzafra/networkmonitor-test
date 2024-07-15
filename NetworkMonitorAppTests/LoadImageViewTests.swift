//
//  LoadImageViewTests.swift
//  NetworkMonitorAppTests
//
//  Created by Guillermo Zafra on 15/7/24.
//

import XCTest
import ComposableArchitecture
import SwiftUI
@testable import NetworkMonitorApp

final class LoadImageViewTests: XCTestCase {
    
    @MainActor
    func testOnAppear_WhenRequestSucceeds_DidReceiveLoadedImage() async {
        // Given
        let store = TestStore(
            initialState: LoadImageReducer.State(networkState: .ready)
        ) {
            LoadImageReducer(
                networkMonitor: MockNetworkMonitor(initiallyConnected: true, becomesConnected: true, after: 1),
                fetchImageUseCase: MockFetchImageUseCase()
            )
        }
        store.exhaustivity = .off
        
        // When
        await store.send(.onAppear) {
            $0.networkState = .loading
        }.finish(timeout: 3 * 1_000_000_000)
                
        let loadedImage = LoadedImage(id: "URL", imageData: Data())
        
        // Then
        await store.receive(.didReceiveImage(loadedImage)) { state in
            state.networkState = .completed(.success(loadedImage))
        }
    }
    
    @MainActor
    func testOnAppear_WhenRequestFails_DidReceiveError() async {
        // Given
        let useCase = MockFetchImageUseCase()
        useCase.expectedError = ImageError.noData
        let store = TestStore(
            initialState: LoadImageReducer.State(networkState: .ready)
        ) {
            LoadImageReducer(
                networkMonitor: MockNetworkMonitor(initiallyConnected: true, becomesConnected: true, after: 1),
                fetchImageUseCase: useCase
            )
        }
        store.exhaustivity = .off
        
        // When
        await store.send(.onAppear) {
            $0.networkState = .loading
        }
        
        // Then
        await store.receive(
            .didReceiveError(.cannotLoadImage(error: "The operation couldn’t be completed. (NetworkMonitorApp.ImageError error 1.)"))
        ) { state in
            state.networkState = .completed(
                .failure(.cannotLoadImage(error: "The operation couldn’t be completed. (NetworkMonitorApp.ImageError error 1.)"))
            )
        }
    }
    
    @MainActor
    func testOnAppear_WhenConnectionChanges_DidReceiveStateUpdate() async {
        // Given
        let store = TestStore(
            initialState: LoadImageReducer.State(networkState: .ready)
        ) {
            LoadImageReducer(
                networkMonitor: MockNetworkMonitor(initiallyConnected: false, becomesConnected: true, after: 1),
                fetchImageUseCase: MockFetchImageUseCase()
            )
        }
        store.exhaustivity = .off
        
        // When
        await store.send(.onAppear) {
            $0.networkState = .loading
        }
                
        
        // Then
        await store.receive(.internetStatusChanged(true)) { state in
            state.isInternetConnected = true
        }
    }
}
