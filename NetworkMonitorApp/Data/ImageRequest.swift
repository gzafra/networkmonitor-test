//
//  ImageRequest.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 12/7/24.
//

import SwiftUI

enum ImageError: Error {
    case invalidURL
    case noData
}

protocol ImageRequestProtocol {
    func getImageFrom(urlString: String) async -> Result<Image, Error>
}

struct ImageRequest: ImageRequestProtocol {
    func getImageFrom(urlString: String) async -> Result<Image, Error> {
        guard let url = URL(string: urlString) else {
            return .failure(ImageError.invalidURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: data) else {
                return .failure(ImageError.noData)
            }
            let image = Image(uiImage: uiImage)
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            return .success(image)
        } catch {
            return .failure(error)
        }
    }
}
