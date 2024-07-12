//
//  ResultScreen.swift
//  NetworkMonitorApp
//
//  Created by Guillermo Zafra on 12/7/24.
//

import SwiftUI

struct ResultScreen: View {
    @Environment(\.colorScheme) var colorScheme
    var image: Image

    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(colorScheme == .dark ? Color.black : Color.white)
    }
}

#Preview {
    ResultScreen(image: Image(""))
}
