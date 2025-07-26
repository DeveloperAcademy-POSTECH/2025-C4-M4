//
//  PopupShadow.swift
//  Saboteur
//
//  Created by 이주현 on 7/26/25.
//

import SwiftUI

extension View {
    func modalOverlay<ModalView: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder modalView: @escaping () -> ModalView
    ) -> some View {
        overlay {
            if isPresented.wrappedValue {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    modalView()
                        .background(Color.Ivory.ivory1)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                }
            }
        }
    }
}

struct PopupView: View {
    let popupText: String
    var popupAction: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더
            StrokedText(
                text: "경고",
                strokeWidth: 9,
                strokeColor: .white,
                foregroundColor: UIColor(Color.Emerald.emerald2),
                font: UIFont(name: "MaplestoryOTFBold", size: 33)!,
                numberOfLines: 1,
                kerning: 0,
                // lineHeight: 10,
                textAlignment: .center
            )
            .padding(.vertical, 11)
            .padding(.horizontal, 156)
            .background(Color.Emerald.emerald3)

            // 본문
            VStack(alignment: .center, spacing: 10) {
                Text(popupText)
                    .lineLimit(nil) // 무제한 줄
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }
            .label1Font()
            .foregroundStyle(Color.Emerald.emerald2)
            .padding(.vertical, 35)
            .padding(.horizontal, 70.5)

            Spacer()

            // 하단 버튼
            HStack {
                Spacer()

                FooterButton(action: {
                    popupAction()
                }, title: "확인")
                    .frame(width: 146)

                Spacer()
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 102)
            .background(Color.Ivory.ivory2)
        }
        .padding(0)
        .frame(width: 380, height: 250)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.4)
            .ignoresSafeArea()

        PopupView(popupText: "대기 시간이 초과되어\n인원 설정 화면으로 이동합니다.")
            .background(Color.Ivory.ivory1)
            .cornerRadius(16)
            .shadow(radius: 10)
    }
}
