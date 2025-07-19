//
//  ChoosePlayerView.swift
//  Saboteur
//
//  Created by 이주현 on 7/15/25.
//

import P2PKit
import SwiftUI

struct ChoosePlayerView: View {
    @EnvironmentObject var router: AppRouter
    @State private var selectedPlayerCount: Int?

    var body: some View {
        VStack {
            HStack {
                Button {
                    router.currentScreen = .lobby
                } label: {
                    Image(systemName: "x.circle")
                }
                Spacer()
            }

            Spacer()

            HStack(spacing: 150) {
                ChoosePlayerButton(action: {
                    P2PNetwork.maxConnectedPeers = 1
                    P2PConstants.setGamePlayerCount(2)
                    selectedPlayerCount = selectedPlayerCount == 2 ? nil : 2
                }, title: "2인게임", isSelected: selectedPlayerCount == 2)

                ChoosePlayerButton(action: {
                    P2PNetwork.maxConnectedPeers = 2
                    P2PConstants.setGamePlayerCount(3)
                    selectedPlayerCount = selectedPlayerCount == 3 ? nil : 3
                }, title: "3인게임", isSelected: selectedPlayerCount == 3)

                ChoosePlayerButton(action: {
                    P2PNetwork.maxConnectedPeers = 3
                    P2PConstants.setGamePlayerCount(4)
                    selectedPlayerCount = selectedPlayerCount == 4 ? nil : 4
                }, title: "4인게임", isSelected: selectedPlayerCount == 4)
            }

            Spacer()

            Button(action: { P2PNetwork.resetSession()
                router.currentScreen = .connect
            }) {
                Text("확인")
                    .padding()
                    .border(selectedPlayerCount != nil ? Color.black : Color.gray, width: 1)
                    .foregroundStyle(selectedPlayerCount != nil ? Color.black : Color.gray)
            }
            .buttonStyle(.plain)
            .disabled(selectedPlayerCount == nil)
        }
        .padding()
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
    let title: String
    var isSelected: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .padding()
                .border(isSelected ? Color.red : Color.black, width: 1)
        }
        .buttonStyle(.plain)
        .background(
            Rectangle()
                .fill(isSelected ? Color.red.opacity(0.2) : Color.clear)
        )
    }
}

#Preview {
    ChoosePlayerView()
}
