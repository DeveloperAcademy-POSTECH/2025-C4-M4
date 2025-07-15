//
//  ChangeNameView.swift
//  Saboteur
//
//  Created by 이주현 on 7/15/25.
//
import P2PKit
import SwiftUI

struct ChangeNameView: View {
    @State private var selectedCountry: String
    @State private var nickname: String
    var onNameChanged: () -> Void

    @Binding var isPresented: Bool

    init(isPresented: Binding<Bool>, onNameChanged: @escaping () -> Void) {
        _isPresented = isPresented
        self.onNameChanged = onNameChanged

        let fullName = P2PNetwork.myPeer.displayName
        if let firstSpace = fullName.firstIndex(of: " ") {
            let flag = String(fullName[..<firstSpace])
            let name = String(fullName[fullName.index(after: firstSpace)...])
            _selectedCountry = State(initialValue: flag)
            _nickname = State(initialValue: name)
        } else {
            _selectedCountry = State(initialValue: "🇰🇷")
            _nickname = State(initialValue: fullName)
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()

                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "x.circle")
                }
            }

            Text("닉네임 변경")
                .font(.title2)

            // 국기 드롭다운
            Picker("국적 선택", selection: $selectedCountry) {
                ForEach(["🇰🇷", "🇺🇸", "🇯🇵", "🇫🇷", "🇩🇪", "🇨🇦", "🇧🇷", "🇦🇺", "🇮🇳", "🇨🇳"], id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 100)

            // 닉네임 입력
            TextField("닉네임 입력", text: $nickname)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button("확인") {
                let newDisplayName = "\(selectedCountry) \(nickname)"
                P2PNetwork.resetSession(displayName: newDisplayName)
                onNameChanged()
            }
            .disabled(nickname.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
    }
}

#Preview {
    @State var showModal = true
    return ChangeNameView(isPresented: $showModal) {
        print("닉네임 변경 완료")
    }
}
