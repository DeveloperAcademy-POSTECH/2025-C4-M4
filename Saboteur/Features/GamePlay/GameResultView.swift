//
//  GameResultView.swift
//  Saboteur
//
//  Created by 이주현 on 7/15/25.
//

import MultipeerConnectivity
import P2PKit
import SwiftUI

private let winnerCardWidth: CGFloat = 400
private let winnerCardHeight: CGFloat = 56

private let loserCardWidth: CGFloat = 320
private let loserCardHeight: CGFloat = 40
private let loserCardSpacing: CGFloat = 8

struct GameResultView: View {
    let result: GameResult
    let players: [Peer]
    @EnvironmentObject var router: AppRouter
    @State private var finalPlayers: [Peer] = []

    var body: some View {
        VStack {
            Spacer()
                .frame(height: UIScreen.main.bounds.height * 0.06)
                .layoutPriority(1)

            VStack(spacing: 16) {
                // 승패 문구
                switch result {
                case let .winner(name):
                    ZStack {
                        if name == P2PNetwork.myPeer.id {
                            Image(.resultWin)
                        } else {
                            Image(.resultLose)
                        }
                    }
                }

                // 승패 리스트
                switch result {
                case let .winner(name):
                    VStack {
                        // 승자 카드
                        Group {
                            if let winnerCard = finalPlayers.first(where: { $0.id == name }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .shadow4ColorInner(color: Color.Ivory.ivory3)
                                        .frame(width: winnerCardWidth, height: winnerCardHeight)
                                        .foregroundStyle(Color.Ivory.ivory1)

                                    HStack {
                                        Text("WIN")
                                            .foregroundStyle(Color.Secondary.yellow2)
                                            .body2WideFont()
                                        Spacer()
                                        if winnerCard.id == P2PNetwork.myPeer.id {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .frame(width: 50, height: 20)
                                                    .foregroundStyle(Color.Etc.pink)
                                                Text("ME")
                                                    .label2Font()
                                                    .foregroundStyle(Color.Grayscale.whiteBg)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 18)
                                    .frame(width: winnerCardWidth, height: winnerCardHeight)

                                    Text("\(winnerCard.displayName)")
                                        .foregroundStyle(Color.Emerald.emerald2)
                                        .body2Font()
                                }
                            }
                        }

                        // 패자 카드 (플레이어 수에 따라 다르게 배치)
                        let losers = finalPlayers.filter { $0.id != name }
                        let row1 = Array(losers.prefix(2))
                        let row2 = losers.count > 2 ? [losers[2]] : []

                        if row1.count == 1 {
                            HStack {
                                loserCard(player: row1[0])
                                Spacer()
                            }
                            .frame(width: loserCardWidth)

                            Spacer()
                                .frame(height: loserCardHeight)
                        } else {
                            HStack(spacing: loserCardSpacing) {
                                ForEach(row1, id: \.id) { player in
                                    loserCard(player: player)
                                }
                            }
                            if !row2.isEmpty {
                                HStack {
                                    loserCard(player: row2[0])
                                    Spacer()
                                }
                                .frame(width: loserCardWidth * 2 + loserCardSpacing)
                            }
                        }
                    }
                }

                // 하단 이동 버튼
                HStack(spacing: 35) {
                    Button {
                        router.currentScreen = .none

                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            GameStateManager.shared.current = .unstarted
                            P2PNetwork.updateGameState()

                            router.currentScreen = .connect
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 50)
                                .shadow3BlackInner()
                                .foregroundStyle(Color.Secondary.blue4)
                                .frame(width: 205, height: 64)

                            Text("다시하기")
                                .foregroundStyle(Color.Grayscale.whiteBg)
                                .title2Font()
                        }
                    }

                    Button {
                        router.currentScreen = .choosePlayer
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 50)
                                .shadow3BlackInner()
                                .foregroundStyle(Color.Secondary.yellow2)
                                .frame(width: 205, height: 64)

                            Text("나가기")
                                .foregroundStyle(Color.Grayscale.whiteBg)
                                .title2Font()
                        }
                    }
                }
            }

            Spacer()
                .frame(height: UIScreen.main.bounds.height * 0.08)
                .layoutPriority(1)
        }
        .task {
            if let storedPeers = UserDefaults.standard.array(forKey: "FinalPeers") as? [[String: String]] {
                finalPlayers = storedPeers.compactMap { dict in
                    if let id = dict["id"], let displayName = dict["displayName"] {
                        return Peer(MCPeerID(displayName: displayName), id: id)
                    } else {
                        return nil
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                P2PNetwork.outSession()
                P2PNetwork.removeAllDelegates()
            }
//            P2PNetwork.outSession()
//            P2PNetwork.removeAllDelegates()
        }
    }

    private var resultTexts: [String] {
        switch result {
        case let .winner(name):
            return finalPlayers.map { $0.id == name ? "\($0.displayName) 승리!" : "\($0.displayName) 패배" }
        }
    }
}

// MARK: - Loser Card ViewBuilder

extension GameResultView {
    @ViewBuilder
    private func loserCard(player: Peer) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .shadow4ColorInner(color: Color.Ivory.ivory3)
                .foregroundStyle(Color.Ivory.ivory2)
                .frame(width: loserCardWidth, height: loserCardHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.Ivory.ivory3, lineWidth: 1)
                )

            HStack {
                Text("LOSE")
                    .foregroundStyle(Color.Secondary.blue1)
                    .label1Font()
                Spacer()
                if player.id == P2PNetwork.myPeer.id {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: 50, height: 20)
                            .foregroundStyle(Color.Secondary.blue1)
                        Text("ME")
                            .label2Font()
                            .foregroundStyle(Color.Grayscale.whiteBg)
                    }
                }
            }
            .padding(.horizontal, 14)
            .frame(width: loserCardWidth, height: loserCardHeight)

            Text("\(player.displayName)")
                .foregroundStyle(Color.Emerald.emerald2)
                .label1Font()
        }
        .frame(width: loserCardWidth, height: loserCardHeight)
        .clipped()
    }
}

#Preview {
    let peer1 = Peer(MCPeerID(displayName: "🇰🇷 Judy"), id: "judy-id")
    let peer2 = Peer(MCPeerID(displayName: "🇺🇸 Alex"), id: "alex-id")
    let players = [peer1, peer2]

    return GameResultView(
        result: .winner(""), // 승자 없음
        players: players
    )
    .environmentObject(AppRouter())
}
