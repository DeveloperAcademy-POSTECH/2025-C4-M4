//
//  GameResultView.swift
//  Saboteur
//
//  Created by 이주현 on 7/15/25.
//

import P2PKit
import SwiftUI

struct GameResultView: View {
    let result: GameResult
    let players: [String]
    let myName: String
    @EnvironmentObject var router: AppRouter

    var body: some View {
        VStack {
            // 승패 문구
            switch result {
            case let .winner(name):
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(name == myName ? Color.green : Color.red)
                        .frame(width: 200, height: 80)

                    Text(name == myName ? "WIN!" : "LOSE")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                .padding()
            case .draw:
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray)
                        .frame(width: 200, height: 80)

                    Text("DRAW")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                .padding()
            }

            // 참가자 리스트
            switch result {
            case let .winner(name):
                VStack(spacing: 3) {
                    // 승자 카드
                    if let winnerCard = players.first(where: { $0 == name }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(Color.blue)
                                .frame(width: 300, height: 70)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.black, lineWidth: winnerCard == myName ? 2 : 0)
                                )
                            Text("\(winnerCard) 승리!")
                                .font(.largeTitle)
                        }
                        .padding(.bottom, 20)
                    }

                    // 패자 카드
                    ForEach(players.filter { $0 != name }, id: \.self) { player in
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(Color.gray)
                                .frame(width: 300, height: 50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.black, lineWidth: player == myName ? 2 : 0)
                                )
                            Text("\(player) 패배")
                                .font(.title2)
                                .padding(2)
                        }
                        .padding(.top, 10) // 승자와 패자 간 간격
                    }
                }
            case .draw:
                Text("무승부")
                    .font(.title2)
                    .padding(2)
            }

            // 이동 버튼
            HStack(spacing: 30) {
                Button("다시 시작") {
                    router.currentScreen = .none

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        router.currentScreen = .connect
                    }
                }
                Button("나가기") {
                    router.currentScreen = .choosePlayer
                }
            }
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
        case .draw:
            return ["무승부"]
        }
    }
}

#Preview {
    GameResultView(result: .winner("🇰🇷 JudyJ"), players: ["🇰🇷 JudyJ", "🇰🇷 Nike", "🇰🇷 Sky"], myName: "🇰🇷 JudyJ")
        .environmentObject(AppRouter())
}
