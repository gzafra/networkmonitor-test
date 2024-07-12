//
//  LoadingScreen.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 12/7/24.
//

import SwiftUI

struct LoadingScreen: View {
    @ObservedObject var flow: Flow
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        switch flow.state {
        case .loading(let isConnected):
            VStack(spacing: 24) {
                Spacer()
                if !isConnected {
                    Text("No Connection")
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
                ErrorScreen(flow: flow)
            }
        case .error:
            ErrorScreen(flow: flow)
        }
    }
    
    var loadingIndicator: some View {
        ProgressView()
            .scaleEffect(2)
    }
}

#Preview {
    LoadingScreen(flow: Flow())
}
