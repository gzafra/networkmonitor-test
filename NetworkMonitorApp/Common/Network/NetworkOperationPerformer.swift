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
    private var ongoingTask: Task<SomeType?, Never>?
    
    init(networkMonitor: any NetworkMonitorProtocol = NetworkMonitor()) {
        self.networkMonitor = networkMonitor
    }
    
    func perform(withinSeconds timeoutDuration: TimeInterval, 
                 using closure: @escaping @Sendable () async -> SomeType
    ) async -> SomeType? {
        if self.networkMonitor.isConnected {
            ongoingTask = Task {
                guard !Task.isCancelled else { return nil }
                return await closure()
            }
            return await ongoingTask?.value
        }
        
        return await withTaskGroup(of: SomeType?.self) { group in
            var result: SomeType? = nil
            
            let connectionTask = Task<SomeType?, Never> {
                for await isConnected in self.networkMonitor.isConnectedPublisher.values {
                    if isConnected {
                        return await closure()
                    }
                }
                return nil
            }
            
            group.addTask {
                try? await Task.sleep(nanoseconds: UInt64(timeoutDuration * 1_000_000_000))
                connectionTask.cancel()
                return nil
            }
            
            group.addTask {
                return await connectionTask.value
            }
            
            self.ongoingTask = connectionTask
            
            for await value in group {
                if let value = value {
                    result = value
                    group.cancelAll()
                    break
                }
            }
            
            self.ongoingTask = nil
            return result
        }
    }
    
    /// Cancels the network operation.
    public func cancel() {
        ongoingTask?.cancel()
    }
}
