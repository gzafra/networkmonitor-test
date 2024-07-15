//
//  MainFlow.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 12/7/24.
//

import SwiftUI
import Network
import Combine

enum FlowState {
    case loading(isConnected: Bool)
    case loaded
    case error
}

@MainActor
class Flow: ObservableObject {
    private enum Constants {
        static let imageUrl = "https://fastly.picsum.photos/id/4/5000/3333.jpg?hmac=ghf06FdmgiD0-G4c9DdNM8RnBIN7BO0-ZGEw47khHP4"
    }
    @Published var state: FlowState = .loading(isConnected: true)
    @Published var image: Image? = nil
    private let operationPerformer = NetworkOperationPerformer<Result<ImageDataModel, Error>?>()
    private let imageTask = ImageRequest()
    private let networkMonitor = MockNetworkMonitor(initiallyConnected: true, becomesConnected: false, after: 1) // Mock just for testing purposes
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        networkMonitor.isConnectedPublisher
            .sink { [weak self] isConnected in
                self?.state = .loading(isConnected: isConnected)
            }
            .store(in: &cancellables)
    }

    func loadData() {
        state = .loading(isConnected: networkMonitor.isConnected)
        Task {
            let result = await operationPerformer.perform(withinSeconds: 3) { [weak self] in
                return await self?.imageTask.getImageFrom(urlString: Constants.imageUrl)
            }
            switch result {
            case .success(let model):
                self.image = Image(data: model.data)
                state = .loaded
            case .failure: // TODO: Handle error?
                state = .error
            default:
                state = .error
            }
        }
    }
}
