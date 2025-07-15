//
//  ChoosePlayerView.swift
//  Saboteur
//
//  Created by 이주현 on 7/15/25.
//

import P2PKit
import SwiftUI

struct ChoosePlayerView: View {
    @Binding var showPlayerModal: Bool
    @EnvironmentObject var router: AppRouter

    var body: some View {
        VStack {
            HStack {
                Spacer()

                Button {
                    showPlayerModal = false
                } label: {
                    Image(systemName: "x.circle")
                }
            }

            VStack(spacing: 50) {
                Button("2인 게임") {
                    P2PNetwork.maxConnectedPeers = 1
                    P2PConstants.setGamePlayerCount(2)
                    P2PNetwork.resetSession()
                    showPlayerModal = false
                    router.currentScreen = .connect
                }
                Button("3인 게임") {
                    P2PNetwork.maxConnectedPeers = 2
                    P2PConstants.setGamePlayerCount(3)
                    P2PNetwork.resetSession()
                    showPlayerModal = false
                    router.currentScreen = .connect
                }
                Button("4인 게임") {
                    P2PNetwork.maxConnectedPeers = 3
                    P2PConstants.setGamePlayerCount(4)
                    P2PNetwork.resetSession()
                    showPlayerModal = false
                    router.currentScreen = .connect
                }
            }
        }
    }
}
