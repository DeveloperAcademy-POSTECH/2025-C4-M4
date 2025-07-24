//
//  DropShadow+extension.swift
//  Saboteur
//
//  Created by 이주현 on 7/22/25.
//

import Foundation
import SwiftUI

// 버튼 드롭 쉐도우 - 인원 설정 버튼은 해당 뷰에서 따로 구현됨
extension View {
    func blackdropShadow() -> some View {
        shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
    }

    func colordropShadow(color: Color = Color.black) -> some View {
        shadow(color: color, radius: 0, x: 0, y: 2)
    }
}

// fill()은 Shape 전용 메서드
extension Shape {
    func innerShadow(
        color: Color = .black.opacity(0.1),
        radius: CGFloat = 1,
        x: CGFloat = 0,
        y: CGFloat = -1
    ) -> some View {
        fill(.shadow(.inner(color: color, radius: radius, x: x, y: y)))
    }
}

// 사용 예시
struct DropShadowExample: View {
    @State private var isSelected: Bool = false

    var body: some View {
        ZStack {
            Color.gray

            VStack {
                Text("black drop shadow")
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.red)
                    .frame(width: 100, height: 100)
                    .blackdropShadow()

                Text("color drop shadow")
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.Etc.green)
                    .frame(width: 100, height: 100)
                    .colordropShadow(color: Color(hex: "2F5746"))

                Text("inner shadow")
                RoundedRectangle(cornerRadius: 20)
                    .innerShadow()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.red)

                Text("inner shadow")
                Button {
                    isSelected = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isSelected = false
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.shadow(.inner(color: Color.black.opacity(0.1), radius: 1, x: 0, y: isSelected ? -2 : 0)))
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.red)
                        .offset(y: isSelected ? 2 : 0)
                        .animation(.easeOut(duration: 0.005), value: isSelected)
                }
            }
        }
    }
}

#Preview {
    DropShadowExample()
}
