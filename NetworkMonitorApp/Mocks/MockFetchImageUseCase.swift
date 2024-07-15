//
//  MockFetchImageUseCase.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 15/7/24.
//

import SwiftUI

final class MockFetchImageUseCase: FetchImageUseCaseProtocol {
    public var url = "URL"
    public var imageData = Data()
    public var expectedError: Error?
    
    func getImage() async -> Result<ImageDataModel, any Error> {
        guard let error = expectedError else {
            let model = ImageDataModel(data: imageData, url: url)
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            return .success(model)
        }
        return .failure(error)
    }
}
