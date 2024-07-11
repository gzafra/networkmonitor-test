//
//  NetworkMonitorAppTests.swift
//  NetworkMonitorAppTests
//
//  Created by Guillermo Zafra on 11/7/24.
//

import XCTest
@testable import NetworkMonitorApp

class NetworkOperationPerformerTests: XCTestCase {
    var sut: NetworkOperationPerformer!
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
        let _ = await sut.perform(withinSeconds: 2) {
            expectation.fulfill()
        }
    }

    func testPerform_WhenInitiallyDisconnectedAndBecomesConnected_ShouldReturnResult() async throws {
        // Given
        let mockNetworkMonitor = MockNetworkMonitor(initiallyConnected: false, becomesConnected: true)
        sut = await NetworkOperationPerformer(networkMonitor: mockNetworkMonitor)
        let expectation = XCTestExpectation(description: "Closure called")
        
        // Then
        let _ = await sut.perform(withinSeconds: 2) {
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 3)
    }

    func testPerform_WhenInitiallyDisconnectedAndRemainsDisconnected_ShouldReturnNil() async throws {
        // Given
        mockNetworkMonitor = MockNetworkMonitor(initiallyConnected: false, becomesConnected: false)
        sut = await NetworkOperationPerformer(networkMonitor: mockNetworkMonitor)
        let expectation = XCTestExpectation(description: "Closure called")
        expectation.isInverted = true
        
        // Then
        let _ = await sut.perform(withinSeconds: 2) {
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 3)
    }
}

