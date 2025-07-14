//
//  0-1-DuoGameView.swift
//  P2PKitDemo

import P2PKit
import SwiftUI

struct DuoGameView: View {
    @StateObject private var connected = DuoConnectedPeers()
    @State private var state: DuoGameTabState = .unstarted

    @State private var countdown: Int? = nil
    @State private var countdownTimer: Timer? = nil

    var body: some View {
        ZStack {
            if state == .unstarted {
                Text("2인 게임")
                LobbyView(connected: connected) {
                    if connected.peers.count == 1 {
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
            } else {
                GameView()

                if state == .pausedGame {
                    LobbyView(connected: connected) {
                        bigButton("Continue Room") {
                            P2PNetwork.makeMeHost()
                        }
                    }
                    .background(.white)
                }
            }
        }
        .onAppear {
            setupP2PKit(channel: "duo-game")
            connected.start()
        }
        .onChange(of: connected.peers.count) { newCount in
            if newCount == 0, state == .startedGame {
                state = .pausedGame
            } else if newCount == 1, state == .unstarted {
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
                if connected.peers.count == 1 {
                    P2PNetwork.makeMeHost()
                    state = .startedGame
                }
            }
        }
    }
}

private enum DuoGameTabState {
    case unstarted
    case startedGame
    case pausedGame
}
