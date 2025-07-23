//
//  ChoosePlayerView.swift
//  Saboteur
//
//  Created by 이주현 on 7/15/25.
//

import P2PKit
import SwiftUI

@ViewBuilder
private func customVerticalSpacer() -> some View {
    Spacer()
        .frame(height: 45)
}

struct ChoosePlayerView: View {
    @EnvironmentObject var router: AppRouter
    @State private var selectedPlayerCount: Int?

    var body: some View {
        ZStack {
            Image(.background)
                .resizable()
                .ignoresSafeArea()

            VStack {
                // 상단 헤더
                ZStack(alignment: .bottom) {
                    HStack {
                        Button {
                            router.currentScreen = .lobby
                        } label: {
                            Image(.backButton)
                        }
                        Spacer()
                    }
                    .customPadding(.header)

                    // 인원 설정
                    HStack {
                        Spacer()

                        StrokedText(
                            text: "인원 설정",
                            strokeWidth: 9,
                            strokeColor: .white,
                            foregroundColor: UIColor(Color.Emerald.emerald2),
                            font: UIFont(name: "MaplestoryOTFBold", size: 33)!,
                            numberOfLines: 1,
                            kerning: 0,
                            // lineHeight: 10,
                            textAlignment: .center
                        )
                        .dropShadow()
                        .frame(height: 50)

                        Spacer()
                    }
                }

                Spacer()
                // customVerticalSpacer()

                // 인원 선택 버튼
                HStack(spacing: 40) {
                    ChoosePlayerButton(action: {
                        P2PNetwork.maxConnectedPeers = 1
                        P2PConstants.setGamePlayerCount(2)
                        selectedPlayerCount = selectedPlayerCount == 2 ? nil : 2
                    }, imageName: .twoPlayer, isSelected: selectedPlayerCount == 2)

                    ChoosePlayerButton(action: {
                        P2PNetwork.maxConnectedPeers = 2
                        P2PConstants.setGamePlayerCount(3)
                        selectedPlayerCount = selectedPlayerCount == 3 ? nil : 3
                    }, imageName: .threePlayer, isSelected: selectedPlayerCount == 3)

                    ChoosePlayerButton(action: {
                        P2PNetwork.maxConnectedPeers = 3
                        P2PConstants.setGamePlayerCount(4)
                        selectedPlayerCount = selectedPlayerCount == 4 ? nil : 4
                    }, imageName: .fourPlayer, isSelected: selectedPlayerCount == 4)
                }

                Spacer()
                // customVerticalSpacer()

                // 하단 버튼
                Button(action: { P2PNetwork.resetSession()
                    router.currentScreen = .connect
                }) {
                    FooterButton(title: "확인", isDisabled: selectedPlayerCount == nil)
                        .customPadding(.footer)
                }
                .buttonStyle(.plain)
                .allowsHitTesting(selectedPlayerCount != nil)

                Spacer()
                // .frame(height: UIScreen.main.bounds.height * 0.08)
            }
        }
    }

    //: : 나중에 적용
    func startGame(with count: Int) {
        P2PConstants.setGamePlayerCount(count)
        P2PNetwork.maxConnectedPeers = count - 1
        P2PNetwork.resetSession()
        router.currentScreen = .connect
    }
}

struct ChoosePlayerButton: View {
    let action: () -> Void
    let imageName: ImageResource
    var isSelected: Bool = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .frame(width: 152, height: 152)
                    .foregroundStyle(isSelected ? Color.Ivory.ivory2 : Color.Ivory.ivory1)
                    .dropShadow()

                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72)
            }
        }
    }
}

#Preview {
    ChoosePlayerView()
}
