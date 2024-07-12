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
                loadingIndicator(isConnected: true)
            case let .completed(.success(astronomyPictures)):
                success(with: astronomyPictures)
            case .completed(.failure):
                VStack {
                    Text(Strings.errorMessage)
                }
                .background(colorScheme == .dark ? Color.black : Color.white)
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
}

// MARK: - Constants

extension LoadImageView {
    enum Strings {
        static let noConnection = "No Connection"
        static let errorMessage = "Image could not be loaded"
    }
}

// MARK: - States & helpers

extension LoadImageView {
    fileprivate func loadingIndicator(isConnected: Bool) -> some View {
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
    
    fileprivate func success(with loadedImage: LoadedImage) -> some View {
        ZStack(alignment: .top) {
            // Scrollable content
            loadedImage.image
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(colorScheme == .dark ? Color.black : Color.white)
        }
        .foregroundColor(colorScheme == .dark ? .white : .black)
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
        LoadImageReducer()
    }
    return LoadImageView(store: store)
}

#Preview {
    let store: Store<LoadImageReducer.State, LoadImageReducer.Action> = .init(
        initialState: .loading
    ) {
        LoadImageReducer()
    }
    return LoadImageView(store: store)
}

#Preview {
    let store: Store<LoadImageReducer.State, LoadImageReducer.Action> = .init(
        initialState: .failure
    ) {
        LoadImageReducer()
    }
    return LoadImageView(store: store)
}

#endif
