//
//  HeaderButton.swift
//  Saboteur
//
//  Created by 이주현 on 7/25/25.
//

import SwiftUI

struct HeaderButton: View {
    let image: Image

    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .frame(width: 64)
            .padding(.top, -2)
    }
}

struct HeaderButtonPreview: View {
    var body: some View {
        VStack {
            HStack {
                HeaderButton(image: Image(.profileButton))
                Spacer()
                HeaderButton(image: Image(.backButton))
            }
            .ignoresSafeArea()
            .customPadding(.header)

            Spacer()
        }
    }
}

#Preview {
    HeaderButtonPreview()
}
