//
//  Padding.swift
//  Saboteur
//
//  Created by 이주현 on 7/23/25.
//

import SwiftUI

enum CustomPaddingType {
    case header
    case footer
}

extension View {
    func customPadding(_ type: CustomPaddingType) -> some View {
        switch type {
        case .header:
            return padding(.horizontal, 64)
        case .footer:
            return padding(.horizontal, 280)
        }
    }
}

// 사용예시
struct CustomPaddingView: View {
    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()

            VStack(spacing: 30) {
                HStack {
                    Spacer()
                    HeaderButton(image: Image(.profileButton))
                }
                .customPadding(.header)

                FooterButton(title: "게임하기")
                    .customPadding(.footer)

                Spacer()
            }
        }
    }
}

#Preview {
    CustomPaddingView()
}
