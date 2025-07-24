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
                    .ignoresSafeArea()

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
                        .blackdropShadow()
                        .frame(height: 50)

                        Spacer()
                    }
                }

                Spacer()
                // customVerticalSpacer()

                // 인원 선택 버튼
                HStack(spacing: 40) {
                    ChoosePlayerButton(
                        action: {
                            P2PNetwork.maxConnectedPeers = 1
                            P2PConstants.setGamePlayerCount(2)
                            selectedPlayerCount = 2
                        },
                        selectedImage: .twoPlayerSelect,
                        unselectedImage: .twoPlayerUnselect,
                        isSelected: selectedPlayerCount == 2
                    )

                    ChoosePlayerButton(action: {
                                           P2PNetwork.maxConnectedPeers = 2
                                           P2PConstants.setGamePlayerCount(3)
                                           selectedPlayerCount = 3
                                       },
                                       selectedImage: .threePlayerSelect,
                                       unselectedImage: .threePlayerUnselect,
                                       isSelected: selectedPlayerCount == 3)

                    ChoosePlayerButton(action: {
                        P2PNetwork.maxConnectedPeers = 3
                        P2PConstants.setGamePlayerCount(4)
                        selectedPlayerCount = 4
                    }, selectedImage: .fourPlayerSelect,
                    unselectedImage: .fourPlayerUnselect, isSelected: selectedPlayerCount == 4)
                }

                Spacer()

                FooterButton(action: {
                    P2PNetwork.resetSession()
                    router.currentScreen = .connect
                }, title: "확인", isDisabled: selectedPlayerCount == nil)
                    .allowsHitTesting(selectedPlayerCount != nil)
                    .customPadding(.footer)

                Spacer()
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
    let selectedImage: ImageResource?
    let unselectedImage: ImageResource?
    var isSelected: Bool = false

    // For backward compatibility: if only one image is given, use it for both states
    init(
        action: @escaping () -> Void,
        selectedImage: ImageResource,
        unselectedImage: ImageResource,
        isSelected: Bool = false
    ) {
        self.action = action
        self.selectedImage = selectedImage
        self.unselectedImage = unselectedImage
        self.isSelected = isSelected
    }

    // For old usage with only one image
    init(
        action: @escaping () -> Void,
        imageName: ImageResource,
        isSelected: Bool = false
    ) {
        self.action = action
        selectedImage = imageName
        unselectedImage = imageName
        self.isSelected = isSelected
    }

    var currentImage: ImageResource {
        isSelected ? (selectedImage ?? .twoPlayerSelect) : (unselectedImage ?? .twoPlayerUnselect)
    }

    var body: some View {
        ZStack {
            Circle()
                .frame(width: 152, height: 152)
                .foregroundStyle(isSelected ? Color.Ivory.ivory2 : Color.Ivory.ivory1)
                .shadow(color: Color.Ivory.ivory2, radius: 0, x: 0, y: isSelected ? 0 : 5)

            Image(currentImage)
                .resizable()
                .scaledToFit()
                .frame(width: 72)
        }

        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(DragGesture(minimumDistance: 0))
        .offset(y: isSelected ? 0 : -2)
        .animation(.easeOut(duration: 0.005), value: isSelected)
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    ChoosePlayerView()
}
