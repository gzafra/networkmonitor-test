//
//  LoadingScreen.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 12/7/24.
//

import SwiftUI

struct LoadingScreen: View {
    @EnvironmentObject var flow: Flow
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        switch flow.state {
        case .loading(let isConnected):
            VStack(spacing: Constants.verticalSpacing) {
                Spacer()
                if !isConnected {
                    Text(Strings.noConnection)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                loadingIndicator
                Spacer()
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
            .edgesIgnoringSafeArea(.all)
        case .loaded:
            if let image = flow.image {
                ResultScreen(image: image)
            } else {
                ErrorScreen()
                    .environmentObject(flow)
            }
        case .error:
            ErrorScreen(
            ).environmentObject(flow)
        }
    }
    
    var loadingIndicator: some View {
        ProgressView()
            .scaleEffect(Constants.loaderScale)
    }
}

// MARK: - Constants

extension LoadingScreen {
    enum Strings {
        static let noConnection = "No Connection"
    }
    
    enum Constants {
        static let loaderScale: CGFloat = 2
        static let verticalSpacing: CGFloat = 12
    }
}

#if DEBUG

// MARK: Previews

#Preview {
    LoadingScreen()
        .environmentObject(Flow.mock)
}

#endif
