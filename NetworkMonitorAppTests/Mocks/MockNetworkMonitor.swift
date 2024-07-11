//
//  MockNetworkMonitor.swift
//  NetworkMonitorAppTests
//
//  Created by Guillermo Zafra on 11/7/24.
//

import Foundation
import Combine
@testable import NetworkMonitorApp

class MockNetworkMonitor: NetworkMonitorProtocol {
    @Published var isConnected: Bool
    private var cancellable: AnyCancellable?
    
    public var isConnectedPublisher: AnyPublisher<Bool, Never> {
        $isConnected.eraseToAnyPublisher()
    }
    
    deinit {
        cancellable?.cancel()
    }

    init(
        initiallyConnected: Bool,
        becomesConnected: Bool,
        after delay: TimeInterval = 1.0
    ) {
        self.isConnected = initiallyConnected
        
        if initiallyConnected != becomesConnected {
            self.cancellable = Future { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.isConnected = becomesConnected
                    promise(.success(()))
                }
            }.sink { _ in }
        }
    }
}
