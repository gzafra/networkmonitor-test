//
//  ContentView.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 11/7/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            let networkOperationClosure: () async -> Bool = {
                // Long-lasting network operation.
                return true
            }
            let _: Bool? = await NetworkOperationPerformer().perform(withinSeconds: 3) {
                return await networkOperationClosure()
            }
        }
    }
}

#Preview {
    ContentView()
}
