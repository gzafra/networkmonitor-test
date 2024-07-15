//
//  FetchImageUseCase.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 15/7/24.
//

import SwiftUI

protocol FetchImageUseCaseProtocol {
    func getImage() async -> Result<ImageDataModel, Error>
}

public struct FetchImageUseCase: FetchImageUseCaseProtocol {
    private enum Constants {
        static let imageUrl = "https://fastly.picsum.photos/id/4/5000/3333.jpg?hmac=ghf06FdmgiD0-G4c9DdNM8RnBIN7BO0-ZGEw47khHP4"
    }
    private let imageRequest: ImageRequestProtocol
    
    init(imageRequest: any ImageRequestProtocol) {
        self.imageRequest = imageRequest
    }
    
    func getImage() async -> Result<ImageDataModel, Error> {
        await imageRequest.getImageFrom(urlString: Constants.imageUrl)
    }
}
