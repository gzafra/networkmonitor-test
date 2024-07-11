//
//  NetworkMonitor.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 11/7/24.
//

import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")
    
    @Published var isConnected = false

    init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
           
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
        
        monitor.start(queue: queue)
    }
}
