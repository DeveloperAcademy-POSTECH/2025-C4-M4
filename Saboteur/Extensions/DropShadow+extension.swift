//
//  DropShadow+extension.swift
//  Saboteur
//
//  Created by 이주현 on 7/22/25.
//

import Foundation
import SwiftUI

extension View {
    func dropShadow() -> some View {
        shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 2)
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
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.red)
                    .frame(width: 100, height: 100)
                    .dropShadow()

                RoundedRectangle(cornerRadius: 20)
                    .innerShadow()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.red)

                RoundedRectangle(cornerRadius: 20)
                    .innerShadow()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(Color.Ivory.ivory1)

                Image(.resultWinnerBox)
            }
        }
    }
}

#Preview {
    DropShadowExample()
}
