//
//  ContentView.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 11/7/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var flow = Flow()
    
    var body: some View {
        LoadingScreen(flow: flow)
            .onAppear(perform: flow.loadData)
    }
}

#if DEBUG

// MARK: Previews

#Preview {
    ContentView()
}

#endif
