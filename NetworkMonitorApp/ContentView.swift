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
//        .task {
//            let networkOperationClosure: () async -> String = {
//                // Long-lasting network operation.
//                return "Hello world"
//            }
//            let result: String? = await NetworkOperationPerformer().perform(withinSeconds: 3) {
//                return await networkOperationClosure()
//            }
//            print(result ?? "No value")
//        }
    }
}

#Preview {
    ContentView()
}
