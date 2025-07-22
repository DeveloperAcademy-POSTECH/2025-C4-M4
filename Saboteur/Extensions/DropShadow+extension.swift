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

// 사용 예시
struct DropShadowExample: View {
    var body: some View {
        ZStack {
            Color.gray

            RoundedRectangle(cornerRadius: 20)
                .fill(Color.red)
                .frame(width: 200, height: 200)
                .dropShadow()
        }
    }
}

#Preview {
    DropShadowExample()
}
