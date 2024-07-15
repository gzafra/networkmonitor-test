//
//  NetworkMonitorAppApp.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 11/7/24.
//

import SwiftUI

@main
struct NetworkMonitorAppApp: App {
    let networkMonitor = NetworkMonitor()
    let fetchImageUseCase = FetchImageUseCase(imageRequest: ImageRequest())
    
    var body: some Scene {
        WindowGroup {
            LoadImageView(
                store: .init(
                    initialState: .init(networkState: .ready)
                ) {
                    LoadImageReducer(
                        networkMonitor: networkMonitor,
                        fetchImageUseCase: fetchImageUseCase
                    )
                }
            )
        }
    }
}
