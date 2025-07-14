//
//  View+Extensions.swift
//  P2PKitDemo
//
//  Created by Paige Sun on 5/14/24.
//

import SwiftUI

public extension View {
    func p2pButtonStyle() -> some View {
        buttonStyle(.borderedProminent).tint(.mint).foregroundColor(.black)
    }

    func p2pSecondaryButtonStyle() -> some View {
        buttonStyle(.bordered)
            .tint(.mint).foregroundColor(.black)
    }
}

extension Text {
    func p2pTitleStyle() -> some View {
        font(.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 14, leading: 0, bottom: 0, trailing: 0))
    }
}
