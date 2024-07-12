//
//  NetworkMonitorAppTests.swift
//  NetworkMonitorAppTests
//
//  Created by Guillermo Zafra on 11/7/24.
//

import XCTest
@testable import NetworkMonitorApp

class NetworkOperationPerformerTests: XCTestCase {
    var sut: NetworkOperationPerformer<String>!
    var mockNetworkMonitor: MockNetworkMonitor!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        sut = nil
        mockNetworkMonitor = nil
        super.tearDown()
    }

    func testPerform_WhenInitiallyConnected_ShouldCallClosure() async throws {
        // Given
        mockNetworkMonitor = MockNetworkMonitor(initiallyConnected: true, becomesConnected: true)
        sut = await NetworkOperationPerformer(networkMonitor: mockNetworkMonitor)
        let expectation = XCTestExpectation(description: "Closure called")
        
        // Then
        let result: String? = await sut.perform(withinSeconds: 2) {
            expectation.fulfill()
            return "Result"
        }
        await fulfillment(of: [expectation], timeout: 3)
        XCTAssertEqual(result, "Result")
    }

    func testPerform_WhenInitiallyDisconnectedAndBecomesConnected_ShouldCallClosure() async throws {
        // Given
        let mockNetworkMonitor = MockNetworkMonitor(initiallyConnected: false, becomesConnected: true)
        sut = await NetworkOperationPerformer(networkMonitor: mockNetworkMonitor)
        let expectation = XCTestExpectation(description: "Closure called")
        
        // Then
        let result = await sut.perform(withinSeconds: 2) {
            expectation.fulfill()
            return "Result"
        }
        
        await fulfillment(of: [expectation], timeout: 3)
        XCTAssertEqual(result, "Result")
    }

    func testPerform_WhenInitiallyDisconnectedAndRemainsDisconnected_ShouldNotCallClosure() async throws {
        // Given
        mockNetworkMonitor = MockNetworkMonitor(initiallyConnected: false, becomesConnected: false)
        sut = await NetworkOperationPerformer(networkMonitor: mockNetworkMonitor)
        let expectation = XCTestExpectation(description: "Closure called")
        expectation.isInverted = true
        
        // Then
        let result = await sut.perform(withinSeconds: 2) {
            print("Closure executed")
            expectation.fulfill()
            return "Result"
        }
        
        await fulfillment(of: [expectation], timeout: 3)
        XCTAssertNil(result)
    }
    
    func testPerform_WhenInitiallyDisconnectedAndBecomesConnectedButCancelledBefore_ShouldNotCallClosure() async throws {
        // Given
        mockNetworkMonitor = MockNetworkMonitor(initiallyConnected: false, becomesConnected: true, after: 2)
        sut = await NetworkOperationPerformer(networkMonitor: mockNetworkMonitor)
        let expectation = XCTestExpectation(description: "Closure called")
        expectation.isInverted = true
        
        // When
        let performTask = Task {
            return await sut.perform(withinSeconds: 3) {
                let nanoseconds = UInt64(5 * 1_000_000_000)
                try? await Task.sleep(nanoseconds: nanoseconds)
                expectation.fulfill()
                return "Result"
            }
        }

        let cancelTask = Task {
            let nanoseconds = UInt64(0.5 * 1_000_000_000) // 1 second delay
            try? await Task.sleep(nanoseconds: nanoseconds)
            print("Cancelling")
            await sut.cancel()
        }
        
        
        // Then
        let result = await performTask.value
        _ = await cancelTask.value
        
        await fulfillment(of: [expectation], timeout: 3)
        XCTAssertNil(result)
    }
    
    func testPerform_WhenInitiallyConnectedButCancelledBefore_ShouldNotCallClosure() async throws {
        // Given
        mockNetworkMonitor = MockNetworkMonitor(initiallyConnected: true, becomesConnected: true, after: 2)
        sut = await NetworkOperationPerformer(networkMonitor: mockNetworkMonitor)
        let expectation = XCTestExpectation(description: "Closure called")
        expectation.isInverted = true
        
        // When
        let performTask = Task {
            return await sut.perform(withinSeconds: 3) {
                print("Task started")
                let nanoseconds = UInt64(5 * 1_000_000_000)
                try? await Task.sleep(nanoseconds: nanoseconds)
                guard !Task.isCancelled else { return "" }
                print("Task finished")
                expectation.fulfill()
                return "Result"
            }
        }

        let cancelTask = Task {
            let nanoseconds = UInt64(0.5 * 1_000_000_000) // 1 second delay
            try? await Task.sleep(nanoseconds: nanoseconds)
            print("Cancelling")
            await sut.cancel()
        }
        
        
        // Then
        let result = await performTask.value
        _ = await cancelTask.value
        
        await fulfillment(of: [expectation], timeout: 3)
        XCTAssertNotEqual(result, "Result")
    }
}

