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
        VStack(spacing: 0) {
            // 상단 헤더
            ZStack {
                HStack {
                    Spacer()
                    StrokedText(
                        text: "프로필",
                        strokeWidth: 9,
                        strokeColor: .white,
                        foregroundColor: UIColor(Color.Emerald.emerald2),
                        font: UIFont(name: "MaplestoryOTFBold", size: 33)!,
                        numberOfLines: 1,
                        kerning: 0,
                        // lineHeight: 10,
                        textAlignment: .center
                    )

                    Spacer()
                }
                .frame(height: 50)

                HStack {
                    Spacer()

                    Button {
                        isPresented = false
                    } label: {
                        Image(.xButton)
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 16)
            .background(Color.Emerald.emerald3)

            Spacer()

            // 입력 부분
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 20) {
                    Menu {
                        Picker("국적 선택", selection: $selectedCountry) {
                            ForEach(["🇰🇷", "🇺🇸", "🇯🇵", "🇫🇷", "🇩🇪", "🇨🇦", "🇧🇷", "🇦🇺", "🇮🇳", "🇨🇳"], id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                    } label: {
                        HStack(spacing: 10) {
                            Text(selectedCountry)
                                .font(.system(size: 40))
                            Image(.dropdownButton)
                        }
                        .foregroundStyle(Color.Ivory.ivory1)
                        .padding(.horizontal, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.Ivory.ivory3, lineWidth: 1)
                                .frame(height: 56)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.Ivory.ivory3, lineWidth: 4)
                                        .blur(radius: 0)
                                        .mask(
                                            RoundedRectangle(cornerRadius: 10)
                                                .offset(y: 4)
                                                .frame(height: 60)
                                        )
                                )
                        }
                    }
                    .frame(height: 56)

                    VStack(alignment: .leading) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.Ivory.ivory2)

                            TextField("닉네임을 입력해주세요", text: $nickname)
                                .textFieldStyle(.plain)
                                .padding(.horizontal)
                                .foregroundStyle(Color.emerald2)
                                // .foregroundStyle(Color.Ivory.ivory3)
                                .body1Font()
                                .keyboardType(.asciiCapable)
                                .onChange(of: nickname) { newValue in
                                    if newValue.count > 8 {
                                        nickname = String(newValue.prefix(8))
                                    }
                                }
                        }
                        .frame(height: 56)

                        Text("*닉네임은 최대 영문 8자까지 입력 가능합니다")
                            .label3Font()
                            .foregroundStyle(Color.Ivory.ivory3)
                            .padding(.horizontal)
                            .padding(.leading, -10)
                    }
                }
            }
            .padding()
            .padding(.horizontal, 60)
            .frame(height: 85)

            Spacer()

            // 하단 버튼
            HStack {
                Spacer()
                Button {
                    let newDisplayName = "\(selectedCountry) \(nickname)"
                    P2PNetwork.outSession(displayName: newDisplayName)
                    onNameChanged()
                } label: {
                    FooterButton(title: "적용하기", isDisabled: nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .frame(width: 205)
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .background(Color.Ivory.ivory2)
        }
        .padding(0)
        .frame(width: 572, height: 289)
    }
}

#Preview {
    ChangeNameView(isPresented: .constant(true)) {
        print("닉네임 변경됨")
    }
}

struct InnerShadowViewModifier: ViewModifier {
    var color: Color
    var radius: CGFloat
    var x: CGFloat
    var y: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color, lineWidth: 1)
                    .blur(radius: radius)
                    .offset(x: x, y: y)
                    .mask(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(
                                colors: [.black, .clear],
                                startPoint: .bottom,
                                endPoint: .bottom
                            )
                            )
                    )
            )
    }
}
