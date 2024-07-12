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
            Text("Connection is not available")
            Button("Retry") {
                flow.loadData()
            }
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}

#Preview {
    ErrorScreen(flow: Flow())
}
