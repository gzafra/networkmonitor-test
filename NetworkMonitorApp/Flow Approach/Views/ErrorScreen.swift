//
//  ErrorScreen.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 12/7/24.
//

import SwiftUI

struct ErrorScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var flow: Flow

    var body: some View {
        VStack {
            Text(Strings.errorMessage)
            Button(Strings.retry) {
                flow.loadData()
            }
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}

// MARK: - Constants

extension ErrorScreen {
    enum Strings {
        static let retry = "Retry"
        static let errorMessage = "Image could not be loaded"
    }
}

#if DEBUG

// MARK: Previews

#Preview {
    ErrorScreen(flow: Flow())
}

#endif