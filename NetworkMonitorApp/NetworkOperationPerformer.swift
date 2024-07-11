//
//  NetworkOperationPerformer.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 11/7/24.
//

import Foundation
import Combine

@MainActor
public class NetworkOperationPerformer {
    private let networkMonitor: any NetworkMonitorProtocol
    private var closure: (() async -> Any)?
    private var cancellable: AnyCancellable?

    @MainActor
    init(networkMonitor: any NetworkMonitorProtocol = NetworkMonitor()) {
        self.networkMonitor = networkMonitor
        self.cancellable = networkMonitor.isConnectedPublisher.sink { [weak self] (isConnected: Bool) in
            if isConnected {
                Task {
                    let result = await self?.closure?()
                    self?.closure = nil
                    return result
                }
            }
        }
    }

    deinit {
        cancellable?.cancel()
    }

    @MainActor
    public func perform<SomeType>(
        withinSeconds timeoutDuration: TimeInterval,
        using closure: @escaping @Sendable () async -> SomeType
    ) async -> SomeType? {
        self.closure = closure
        if self.networkMonitor.isConnected {
            return await closure()
        } else {
            await setTimeout(after: timeoutDuration)
            return nil
        }
    }
    
    private func setTimeout(after timeoutDuration: TimeInterval) async {
        let nanoseconds = UInt64(timeoutDuration * 1_000_000_000) // convert seconds to nanoseconds
        try? await Task.sleep(nanoseconds: nanoseconds)
        self.closure = nil
    }
}
