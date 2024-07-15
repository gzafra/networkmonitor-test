//
//  Image+Data.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 15/7/24.
//

import SwiftUI

extension Image {
    init?(data: Data) {
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        self.init(uiImage: uiImage)
    }
}
