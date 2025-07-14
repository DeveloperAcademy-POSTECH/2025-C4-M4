//
//  0-GameStartTab.swift
//  P2PKitDemo
//
//  Created by 이주현 on 7/8/25.
//

import P2PKit
import SwiftUI

func setupP2PKit(channel: String) {
    P2PConstants.networkChannelName = channel
    P2PConstants.loggerEnabled = true
}

struct GameStartTab: View {
    @State private var selectedGame: GameType?
    @State private var displayName: String = P2PNetwork.myPeer.displayName

    var body: some View {
        VStack {
            Text(displayName)
                .p2pTitleStyle()

            NavigationLink("이름 설정", destination: ChangeNameView(onNameChanged: {
                displayName = P2PNetwork.myPeer.displayName
            }))
            .padding()

            NavigationStack {
                VStack(spacing: 30) {
                    Button("2인 게임") {
                        P2PNetwork.maxConnectedPeers = 2
                        selectedGame = .duo
                    }
                    Button("3인 게임") {
                        P2PNetwork.maxConnectedPeers = 3
                        selectedGame = .triple
                    }
                    Button("4인 게임") {
                        P2PNetwork.maxConnectedPeers = 4
                        selectedGame = .squad
                    }
                }
                .navigationDestination(item: $selectedGame) { game in
                    switch game {
                    case .duo:
                        DuoGameView()
                    case .triple:
                        TripleGameView()
                    case .squad:
                        SquadGameView()
                    }
                }
            }
        }
        .onAppear {
            displayName = P2PNetwork.myPeer.displayName
        }
    }

    enum GameType: Hashable, Identifiable {
        var id: Self { self }
        case duo, triple, squad
    }
}

#Preview {
    GameStartTab()
}
