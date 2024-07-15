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
    @Published var state: FlowState = .loading(isConnected: true)
    @Published var image: Image? = nil
    
    private let operationPerformer = NetworkOperationPerformer<Result<ImageDataModel, Error>?>()
    private var cancellables = Set<AnyCancellable>()
    
    private let fetchImageUseCase: any FetchImageUseCaseProtocol
    private let networkMonitor: any NetworkMonitorProtocol
    
    init(fetchImageUseCase: any FetchImageUseCaseProtocol,
         networkMonitor: any NetworkMonitorProtocol) {
        self.fetchImageUseCase = fetchImageUseCase
        self.networkMonitor = networkMonitor
        self.networkMonitor.isConnectedPublisher
            .sink { [weak self] isConnected in
                self?.state = .loading(isConnected: isConnected)
            }
            .store(in: &cancellables)
    }

    func loadData() {
        state = .loading(isConnected: networkMonitor.isConnected)
        Task {
            let result = await operationPerformer.perform(withinSeconds: 3) { [weak self] in
                return await self?.fetchImageUseCase.getImage()
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
