//
//  FooterButton.swift
//  Saboteur
//
//  Created by 이주현 on 7/23/25.
//

import SwiftUI

struct FooterButton: View {
    var action: () -> Void = {}
    let title: String
    var isDisabled: Bool?
    @State private var isSelected: Bool = false

    var body: some View {
        Button {
            guard isDisabled != true else { return }
            isSelected = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isSelected = false
            }

            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 50)
                    .fill(.shadow(.inner(color: Color.black.opacity(0.1), radius: 0, x: 0, y: isSelected ? 0 : -4)))
                    .frame(width: 205, height: 64)
                    .foregroundStyle(isDisabled == true ? Color.Grayscale.gray : Color.Emerald.emerald2)

                Text(title)
                    .foregroundStyle(Color.Grayscale.whiteBg)
                    .title2Font()
            }
            .offset(y: isSelected ? 4 : 0)
            .animation(.easeOut(duration: 0.005), value: isSelected)
        }
    }
}

struct FooterButtonExample: View {
    @State private var exmaple: Int?

    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()

            FooterButton(action: {
                print("눌림")
            }, title: "하단 버튼")
                .customPadding(.footer)
        }
    }
}

#Preview {
    FooterButtonExample()
}
