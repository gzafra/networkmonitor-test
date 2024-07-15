//
//  LoadImageView.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 12/7/24.
//

import ComposableArchitecture
import SwiftUI

struct LoadImageView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private var store: Store<LoadImageReducer.State, LoadImageReducer.Action>
    
    public init(store: Store<LoadImageReducer.State, LoadImageReducer.Action>) {
        self.store = store
    }
    
    @ViewBuilder
    private var content: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            switch viewStore.networkState {
            case .loading:
                loadingIndicator(isConnected: viewStore.isInternetConnected)
            case let .completed(.success(loadedImage)):
                successScreen(with: loadedImage)
            case .completed(.failure):
                errorScreen()
            case .ready:
                Color.clear
            }
        }
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            content
                .onAppear {
                    store.send(.onAppear)
                }
        }
    }
    
    private func loadingIndicator(isConnected: Bool) -> some View {
        ZStack(alignment: .top) {
            VStack(spacing: 24) {
                Spacer()
                if !isConnected {
                    Text(Strings.noConnection)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                ProgressView()
                    .scaleEffect(2)
                Spacer()
            }
        }
    }
    
    private func successScreen(with loadedImage: LoadedImage) -> some View {
        ResultScreen(image: Image(data: loadedImage.imageData))
    }
    
    private func errorScreen() -> some View {
        VStack {
            Text(Strings.errorMessage)
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}

// MARK: - Constants

extension LoadImageView {
    enum Strings {
        static let noConnection = "No Connection"
        static let errorMessage = "Image could not be loaded"
    }
}

#if DEBUG

// MARK: Previews

struct LoadImageView_Preview {
    struct Preview: View {
        var store: Store<LoadImageReducer.State, LoadImageReducer.Action>
        var body: some View {
            LoadImageView(store: store)
        }
    }
}

#Preview {
    let store: Store<LoadImageReducer.State, LoadImageReducer.Action> = .init(
        initialState: .success
    ) {
        LoadImageReducer(
            networkMonitor: MockNetworkMonitor(initiallyConnected: true, becomesConnected: false, after: 1),
            fetchImageUseCase: MockFetchImageUseCase()
        )
    }
    return LoadImageView(store: store)
}

#Preview {
    let store: Store<LoadImageReducer.State, LoadImageReducer.Action> = .init(
        initialState: .loading
    ) {
        LoadImageReducer(
            networkMonitor: MockNetworkMonitor(initiallyConnected: true, becomesConnected: false, after: 1),
            fetchImageUseCase: MockFetchImageUseCase()
        )
    }
    return LoadImageView(store: store)
}

#Preview {
    let store: Store<LoadImageReducer.State, LoadImageReducer.Action> = .init(
        initialState: .failure
    ) {
        LoadImageReducer(
            networkMonitor: MockNetworkMonitor(initiallyConnected: true, becomesConnected: false, after: 1),
            fetchImageUseCase: MockFetchImageUseCase()
        )
    }
    return LoadImageView(store: store)
}

#endif
