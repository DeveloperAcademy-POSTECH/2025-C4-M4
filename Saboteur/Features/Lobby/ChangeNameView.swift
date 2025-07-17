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

                Text("프로필")
                    .font(.title2)

                Spacer()

                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "x.circle")
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 20) {
                    Menu {
                        Picker("국적 선택", selection: $selectedCountry) {
                            ForEach(["🇰🇷", "🇺🇸", "🇯🇵", "🇫🇷", "🇩🇪", "🇨🇦", "🇧🇷", "🇦🇺", "🇮🇳", "🇨🇳"], id: \.self) {
                                Text($0)
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedCountry)
                            Image(systemName: "chevron.down")
                        }
                        .frame(width: 50, height: 60)
                        .padding(.horizontal) // Match TextField padding
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }

                    VStack(alignment: .leading) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(Color.blue.opacity(0.3))

                            TextField("닉네임 입력", text: $nickname)
                                .textFieldStyle(.plain)
                                .padding(.horizontal)
                                .foregroundStyle(Color.gray)
                        }
                        .frame(width: 400, height: 60)

                        Text("*닉네임은 최대 영문 8자까지 입력 가능합니다")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .padding(.leading, -10)
                    }
                }
            }
            .padding()

            Button {
                let newDisplayName = "\(selectedCountry) \(nickname)"
                P2PNetwork.resetSession(displayName: newDisplayName)
                onNameChanged()
            } label: {
                Text("적용하기")
            }
            .disabled(nickname.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
}

#Preview {
    ChangeNameView(isPresented: .constant(true)) {
        print("닉네임 변경됨")
    }
}
