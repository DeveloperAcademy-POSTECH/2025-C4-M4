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
                    Text("채널: \(P2PConstants.networkChannelName)")
                    Button {
                        P2PNetwork.outSession()
                        P2PNetwork.removeAllDelegates()

                        router.currentScreen = .choosePlayer
                    } label: {
                        Image(systemName: "door.left.hand.open")
                    }
                }

                // 1. 게임 상태가 unstarted면 기본적으로 연결된 사용자와 로딩 화면을 보여주는 ConnectLobbyView을 띄움
                if state == .unstarted {
                    ConnectLobbyView(connected: connected) {
                        // 1-1. 그러다가 인원수가 다 차면 5초 카운트다운이 시작됨
                        if connected.peers.count == P2PNetwork.maxConnectedPeers {
                            if let countdown = countdown {
                                Text("게임이 \(countdown)초 후 시작됩니다")
                                    .font(.title)
                                    .padding()
                            }
                        }
                    }
                }
                //: : 2. 게임 플레이 중에 누군가가 나가서 연결된 사람이 없으면 일단 오류 발생 버튼이 뜸.
                else if state == .pausedGame {
                    ConnectLobbyView(connected: connected) {
                        Button("오류 발생. 다시 돌아가기") {
                            P2PNetwork.outSession()
                            P2PNetwork.removeAllDelegates()
                            router.currentScreen = .choosePlayer
                        }
                    }
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

    private func startCountdown() {
        countdown = 5
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if let current = countdown, current > 1 {
                countdown = current - 1
            } else {
                timer.invalidate()
                countdownTimer = nil
                if connected.peers.count == P2PNetwork.maxConnectedPeers {
                    P2PNetwork.makeMeHost()
                    state = .startedGame
                }
            }
        }
    }
}
