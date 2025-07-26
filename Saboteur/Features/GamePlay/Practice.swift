////
////  Practice.swift
////  Saboteur
////
////  Created by 이주현 on 7/26/25.
////
//
// import SwiftUI
//
// struct Practice: View {
//    var body: some View {
//        VStack(spacing: 30) {
//            // 이전에 놓인 카드
//            .shadow(color: Color.Emerald.emerald1, radius: 0, x: 0, y: 2)
//                .contentShape(Rectangle())
//                // .onTapGesture { onTap() }
//                .zIndex(1)
//                .padding(2)
//                // 가장 최근에 놓인 카드
//                .shadow(color: Color.Emerald.emerald2, radius: 0, x: 0, y: 2)
//                .contentShape(Rectangle())
//                // .onTapGesture { onTap() }
//                .zIndex(1)
//                // 이거 유무
//                .overlay(
//                    RoundedRectangle(cornerRadius: 4)
//                        .stroke(Color.Emerald.emerald2, lineWidth: 1)
//                )
//                .padding(2)
//        }
//    }
// }
//
// #Preview {
//    Practice()
// }
