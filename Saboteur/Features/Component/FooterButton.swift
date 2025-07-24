//
//  FooterButton.swift
//  Saboteur
//
//  Created by 이주현 on 7/23/25.
//

import SwiftUI

struct FooterButton: View {
    let title: String
    var isDisabled: Bool?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 50)
                .innerShadow()
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .foregroundStyle(isDisabled == true ? Color.gray : Color.Emerald.emerald2)

            Text(title)
                .foregroundStyle(Color.Grayscale.whiteBg)
                .title2Font()
        }
    }
}

struct FooterButtonExample: View {
    @State private var exmaple: Int?

    var body: some View {
        FooterButton(title: "하단 버튼")
            .customPadding(.footer)

        FooterButton(title: "하단 버튼", isDisabled: exmaple == nil)
            .customPadding(.footer)
    }
}

#Preview {
    FooterButtonExample()
}
