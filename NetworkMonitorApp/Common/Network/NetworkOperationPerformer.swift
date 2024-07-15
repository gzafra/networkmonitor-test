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
    private var closure: (() async -> SomeType)?
    private var cancellable: AnyCancellable?
    private var task: Task<SomeType, Never>?
    private var timeoutTask: Task<Void, Never>?
    
    
    /// Initializes a new instance of `NetworkOperationPerformer`.
    /// - Parameter networkMonitor: The network monitor to use for checking the network status. Defaults to `NetworkMonitor()`.
    init(networkMonitor: any NetworkMonitorProtocol = NetworkMonitor()) {
        self.networkMonitor = networkMonitor
        self.cancellable = networkMonitor.isConnectedPublisher.sink { [weak self] (isConnected: Bool) in
            if isConnected {
                guard let self, let closure = self.closure else { return }
                print("Becomes connected")
                self.timeoutTask?.cancel()
                self.task = Task {
                    let result = await closure()
                    return result
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
            print("Initially connected")
            self.task = Task {
                let result = await closure()
                return result
            }
        } else {
            print("Initially not connected")
            await setTimeout(after: timeoutDuration)
        }
        print("Actually executing task")
        return await self.task?.value
    }
    
    @MainActor
    private func setTimeout(after timeoutDuration: TimeInterval) async {
        let nanoseconds = UInt64(timeoutDuration * 1_000_000_000)
        self.timeoutTask = Task {
            print("Started timing out")
            try? await Task.sleep(nanoseconds: nanoseconds)
            print("Timed out")
        }
        await self.timeoutTask?.value        
    }
    
    /// Cancels the network operation.
    public func cancel() {
        print("Task cancelled")
        timeoutTask?.cancel()
        task?.cancel()
    }
}
