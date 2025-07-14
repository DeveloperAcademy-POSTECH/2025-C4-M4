//
//  0-2-
// 0-2-TripleGameView.swift
//  P2PKitDemo
//
//  Created by 이주현 on 7/8/25.
//

import P2PKit
import SwiftUI

struct TripleGameView: View {
    @StateObject private var connected = TripleConnectedPeers()
    @State private var state: TripleGameTabState = .unstarted

    @State private var countdown: Int? = nil
    @State private var countdownTimer: Timer? = nil

    var body: some View {
        ZStack {
            if state == .unstarted {
                Text("3인 게임")
                TripleLobbyView(connected: connected) {
                    if connected.peers.count == 2, P2PNetwork.connectedPeers.count == 2 {
                        if let countdown = countdown {
                            Text("게임이 \(countdown)초 후 시작됩니다")
                                .font(.title)
                                .padding()
                        } else {
                            Text("5초 후 게임이 시작됩니다")
                                .font(.title)
                                .padding()
                        }
                    }
                }
            } else {
                GameView()

                if state == .pausedGame {
                    TripleLobbyView(connected: connected) {
                        bigButton("Continue Room") {
                            P2PNetwork.makeMeHost()
                        }
                    }
                    .background(.white)
                }
            }
        }
        .onAppear {
            setupP2PKit(channel: "triple-game")
            connected.start()
        }
        .onChange(of: connected.peers.count) { newCount in
            if newCount == 0, state == .startedGame {
                state = .pausedGame
            } else if newCount == 2, state == .unstarted {
                startCountdown()
            } else {
                // Reset countdown if count deviates from expected 3 players
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
        .p2pButtonStyle()
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
                if connected.peers.count == 2 {
                    P2PNetwork.makeMeHost()
                    state = .startedGame
                }
            }
        }
    }
}

private enum TripleGameTabState {
    case unstarted
    case startedGame
    case pausedGame
}
