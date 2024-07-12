//
//  NetworkMonitorAppApp.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 11/7/24.
//

import SwiftUI

@main
struct NetworkMonitorAppApp: App {
    var body: some Scene {
        WindowGroup {
            LoadImageView(
                store: .init(
                    initialState: .init(networkState: .ready)
                ) {
                    LoadImage()
                }
            )
        }
    }
}
