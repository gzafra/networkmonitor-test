//
//  ImageRequest.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 12/7/24.
//

import Foundation

public enum ImageError: Error {
    case invalidURL
    case noData
}

protocol ImageRequestProtocol {
    func getImageFrom(urlString: String) async -> Result<ImageDataModel, Error>
}

struct ImageRequest: ImageRequestProtocol {
    func getImageFrom(urlString: String) async -> Result<ImageDataModel, Error> {
        guard let url = URL(string: urlString) else {
            return .failure(ImageError.invalidURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let model = ImageDataModel(data: data, url: urlString)
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            return .success(model)
        } catch {
            return .failure(error)
        }
    }
}
