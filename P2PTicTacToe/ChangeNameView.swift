//
//  ChangeNameView.swift
//  P2PKitDemo
//
//  Created by 이주현 on 7/8/25.
//

import P2PKit
import SwiftUI

struct ChangeNameView: View {
    @State private var selectedCountry = "🇰🇷"
    @State private var nickname = ""
    var onNameChanged: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("닉네임 변경")
                .font(.title2)

            // 국기 드롭다운
            Picker("국적 선택", selection: $selectedCountry) {
                ForEach(["🇰🇷", "🇺🇸", "🇯🇵", "🇫🇷", "🇩🇪", "🇨🇦", "🇧🇷", "🇦🇺", "🇮🇳", "🇨🇳"], id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.menu)

            // 닉네임 입력
            TextField("닉네임 입력", text: $nickname)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button("확인") {
                let newDisplayName = "\(selectedCountry) \(nickname)"
                P2PNetwork.resetSession(displayName: newDisplayName)
                onNameChanged()
                dismiss()
            }
            .disabled(nickname.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
    }
}
