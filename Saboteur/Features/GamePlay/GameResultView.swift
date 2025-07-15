//
//  GameResultView.swift
//  Saboteur
//
//  Created by 이주현 on 7/15/25.
//

import P2PKit
import SwiftUI

struct GameResultView: View {
    // let result: GameResult
    @EnvironmentObject var router: AppRouter

    var body: some View {
        VStack {
//            Text(resultText)
//                .font(.largeTitle)
//                .padding()

            Button("다시 시작") {
                //: : 이건 뭘 선택하냐에 따라 바뀌어야 함
                P2PNetwork.maxConnectedPeers = 1
                P2PConstants.setGamePlayerCount(2)

                router.currentScreen = .none
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    router.currentScreen = .connect
                }
            }
            Button("나가기") {
                router.currentScreen = .choosePlayer
            }
        }
        .task {
            P2PNetwork.outSession()
            P2PNetwork.removeAllDelegates()
        }
    }

//    private var resultText: String {
//        switch result {
//        case let .winner(name):
//            return "\(name) 승리!"
//        case .draw:
//            return "무승부"
//        }
//    }
}
