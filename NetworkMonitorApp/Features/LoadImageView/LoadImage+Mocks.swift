//
//  LoadImage+Mocks.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 12/7/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

#if DEBUG


extension LoadImage.State {
  static let loading = Self(networkState: .loading)

  static let success = Self(networkState: .completed(.success(.mock)))

  static let failure = Self(networkState: .completed(.failure(.cannotLoadImage(error: "error"))))
}

extension LoadedImage {
    static let mock = Self(image: Image("image"))
}

#endif
