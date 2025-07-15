//
//  ConnectView.swift
//  Saboteur
//
//  Created by 이주현 on 7/15/25.
//

import Foundation
import P2PKit
import SwiftUI

struct ConnectView: View {
    // let id: String
    @EnvironmentObject var router: AppRouter

    @StateObject private var connected = DuoConnectedPeers()
    @State private var state: GameState = .unstarted

    @State private var countdown: Int? = nil
    @State private var countdownTimer: Timer? = nil

    var body: some View {
        ZStack {
            VStack {
                VStack {
                    // FIX -
//                    Text("\(P2PConstants.gamePlayerCount)인 게임")
                    Text("채널: \(P2PConstants.networkChannelName)")
                    Button {
                        P2PNetwork.outSession()
                        P2PNetwork.removeAllDelegates()

                        router.currentScreen = .choosePlayer
                    } label: {
                        Image(systemName: "door.left.hand.open")
                    }
                }

                if state == .unstarted {
                    ConnectLobbyView(connected: connected) {
                        if connected.peers.count == P2PNetwork.maxConnectedPeers {
                            if let countdown = countdown {
                                Text("게임이 \(countdown)초 후 시작됩니다")
                                    .font(.title)
                                    .padding()
                            } else {
                                Text("연결이 끊어졌습니다")
                                    .font(.title)
                                    .padding()
                            }
                        }
                    }
                } else if state == .pausedGame {
                    LobbyView()
//                    LobbyView(connected: connected) {
//                        bigButton("오류 발생. 다시 돌아가기") {
//                            P2PNetwork.outSession()
//                            P2PNetwork.removeAllDelegates()
//                            router.currentScreen = .choosePlayer
//                        }
//                    }
                        .background(.white)
                } else {
                    GameView(gameState: $state)
                }
            }
            .border(Color.red, width: 10)
        }
        .onAppear {
            P2PNetwork.resetSession()
            connected.start()
        }
        .onChange(of: connected.peers.count) {
            let connectedCount = connected.peers.count
            if connectedCount == 0, state == .startedGame {
                state = .pausedGame
            } else if connectedCount == P2PNetwork.maxConnectedPeers, state == .unstarted {
                startCountdown()
            } else {
                countdown = nil
                countdownTimer?.invalidate()
                countdownTimer = nil
            }
        }
    }

    private func bigButton(_ text: String, action: @escaping () -> Void) -> some View {
        Button(action: action, label: {
            Text(text).padding(10).font(.title)
        })
    }

    private func startCountdown() {
        countdown = 5
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if let current = countdown, current > 1 {
                countdown = current - 1
            } else {
                timer.invalidate()
                countdownTimer = nil
                if connected.peers.count == 1 {
                    P2PNetwork.makeMeHost()
                    state = .startedGame
                }
            }
        }
    }
}
