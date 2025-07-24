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
        shadow(color: Color.black.opacity(0.25), radius: 0, x: 0, y: 2)
    }

    func colordropShadow(color: Color = Color.black) -> some View {
        shadow(color: color, radius: 0, x: 0, y: 2)
    }
}

// fill()은 Shape 전용 메서드
extension Shape {
    func innerShadow(
        radius: CGFloat = 1,
        y: CGFloat = -1
    ) -> some View {
        fill(.shadow(.inner(radius: radius, y: y)))
    }
}

// 사용 예시
struct DropShadowExample: View {
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
            }
        }
    }
}

#Preview {
    DropShadowExample()
}
