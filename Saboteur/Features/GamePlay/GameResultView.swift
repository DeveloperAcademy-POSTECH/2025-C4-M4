//
//  GameResultView.swift
//  Saboteur
//
//  Created by 이주현 on 7/15/25.
//

import P2PKit
import SwiftUI

private let winnerCardWidth: CGFloat = 400
private let winnerCardHeight: CGFloat = 56

private let loserCardWidth: CGFloat = 320
private let loserCardHeight: CGFloat = 40
private let loserCardSpacing: CGFloat = 8

struct GameResultView: View {
    let result: GameResult
    let players: [String]
    let myName: String
    @EnvironmentObject var router: AppRouter

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
                        if name == myName {
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
                        if let winnerCard = players.first(where: { $0 == name }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .innerShadow()
                                    .frame(width: winnerCardWidth, height: winnerCardHeight)
                                    .foregroundStyle(Color.Ivory.ivory1)

                                HStack {
                                    Text("WIN")
                                        .foregroundStyle(Color.Secondary.yellow2)
                                        .body2WideFont()
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .frame(width: winnerCardWidth, height: winnerCardHeight)

                                Text("\(winnerCard)")
                                    .foregroundStyle(Color.Emerald.emerald2)
                                    .body2Font()
                            }
                        }

                        // 패자 카드 (플레이어 수에 따라 다르게 배치)
                        let losers = players.filter { $0 != name }
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
                                ForEach(row1, id: \.self) { player in
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

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            router.currentScreen = .connect
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 50)
                                .innerShadow()
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
                                .innerShadow()
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
            P2PNetwork.outSession()
            P2PNetwork.removeAllDelegates()
        }
    }

    private var resultTexts: [String] {
        switch result {
        case let .winner(name):
            return players.map { $0 == name ? "\($0) 승리!" : "\($0) 패배" }
        }
    }
}

// MARK: - Loser Card ViewBuilder

extension GameResultView {
    @ViewBuilder
    private func loserCard(player: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
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
            }
            .padding(.horizontal, 12)
            .frame(width: loserCardWidth, height: loserCardHeight)

            Text("\(player)")
                .foregroundStyle(Color.Emerald.emerald2)
                .label1Font()
        }
        .frame(width: loserCardWidth, height: loserCardHeight)
        .clipped()
    }
}

#Preview {
    GameResultView(result: .winner("🇰🇷 JudyJ"), players: ["🇰🇷 JudyJ", "🇰🇷 Nike", "🇰🇷 Nike"], myName: "🇰🇷 JudyJ")
        .environmentObject(AppRouter())
}
