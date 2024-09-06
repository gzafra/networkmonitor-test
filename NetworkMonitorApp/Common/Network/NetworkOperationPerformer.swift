//
//  NetworkOperationPerformer.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 11/7/24.
//

import Foundation
import Combine

public class NetworkOperationPerformer<SomeType> {
    private let networkMonitor: any NetworkMonitorProtocol
    private var closure: (@Sendable () async -> SomeType)?
    private var cancellable: AnyCancellable?
    
    
    /// Initializes a new instance of `NetworkOperationPerformer`.
    /// - Parameter networkMonitor: The network monitor to use for checking the network status. Defaults to `NetworkMonitor()`.
    init(networkMonitor: any NetworkMonitorProtocol = NetworkMonitor()) {
        self.networkMonitor = networkMonitor
        self.cancellable = networkMonitor.isConnectedPublisher.sink { [weak self] (isConnected: Bool) in
            if isConnected {
                guard let self, let closure = self.closure else { return }
                Task {
                    await self.performNetworkOperation(using: closure, timeoutDuration: 0) // Default timeoutDuration
                }
            }
        }
    }


    deinit {
        cancellable?.cancel()
    }

    /// Performs the network operation.
    /// - Parameters:
    ///   - timeoutDuration: The time interval within which the operation should be performed.
    ///   - closure: The closure to execute when the network is connected.
    /// - Returns: The result of the operation if successful, `nil` otherwise.
    @MainActor
    public func perform(
        withinSeconds timeoutDuration: TimeInterval,
        using closure: @escaping @Sendable () async -> SomeType
    ) async -> SomeType? {
        self.closure = closure
        if self.networkMonitor.isConnected {
            return await performNetworkOperation(using: closure, timeoutDuration: timeoutDuration)
        } else {
            await setTimeout(after: timeoutDuration)
            return nil
        }
    }
    
    @MainActor
    private func performNetworkOperation(using closure: @escaping @Sendable () async -> SomeType, 
                                         timeoutDuration: TimeInterval) async -> SomeType? {
        await withTaskGroup(of: SomeType?.self) { group in
            group.addTask {
                return await closure()
            }
            group.addTask {
                try? await Task.sleep(nanoseconds: UInt64(timeoutDuration * 1_000_000_000))
                return nil
            }
            return await group.next() ?? nil
        }
    }
    
    @MainActor
    private func setTimeout(after timeoutDuration: TimeInterval) async {
        let nanoseconds = UInt64(timeoutDuration * 1_000_000_000)
        try? await Task.sleep(nanoseconds: nanoseconds)
    }
    
    /// Cancels the network operation.
    public func cancel() {
 
    }
}
