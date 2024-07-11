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
    private let networkMonitor: NetworkMonitor
//    private var timer: Timer?
    private var closure: (() async -> Any)?
    private var cancellable: AnyCancellable?

    @MainActor
    init(networkMonitor: NetworkMonitor = NetworkMonitor()) {
        self.networkMonitor = networkMonitor
        self.cancellable = networkMonitor.$isConnected.sink { [weak self] isConnected in
            if isConnected {
                Task {
                    await self?.closure?()
                }
                self?.closure = nil
//                self?.timer?.invalidate()
//                self?.timer = nil
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


//    private func setTimeout(after timeoutDuration: TimeInterval) {
//        self.timer = Timer.scheduledTimer(withTimeInterval: timeoutDuration, repeats: false) { [weak self] _ in
//            self?.closure = nil
//            self?.timer = nil
//        }
//    }
