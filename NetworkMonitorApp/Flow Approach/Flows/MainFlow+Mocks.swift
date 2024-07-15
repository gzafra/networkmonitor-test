//
//  MainFlow+Mocks.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 15/7/24.
//

import Foundation


#if DEBUG

extension FetchImageUseCase {
    static let mock = FetchImageUseCase(imageRequest: ImageRequest())
}

extension Flow {
    static let mock = Flow(fetchImageUseCase: FetchImageUseCase.mock,
                           networkMonitor: NetworkMonitor())
}

#endif
