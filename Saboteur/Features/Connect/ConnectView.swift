//
//  ConnectView.swift
//  Saboteur
//
//  Created by 이주현 on 7/15/25.
//
import Foundation
import MultipeerConnectivity
import P2PKit
import SwiftUI

struct ConnectView: View {
    // let id: String
    @EnvironmentObject var router: AppRouter

    @StateObject var connected = ConnectedPeers()
    @State private var state: GameState = .unstarted

    @State private var countdown: Int? = nil
    @State private var countdownTimer: Timer? = nil

//    // 프리뷰를 볼때 init 실행해야 함
//    init(connected: ConnectedPeers = ConnectedPeers()) {
//        _connected = StateObject(wrappedValue: connected)
//    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button {
                    P2PNetwork.outSession()
                    P2PNetwork.removeAllDelegates()

                    router.currentScreen = .choosePlayer
                } label: {
                    Image(systemName: "door.left.hand.open")
                }

                Spacer()

                // Text("\(P2PConstants.networkChannelName)인 대기방")
                Text("\(P2PNetwork.maxConnectedPeers + 1)인 대기방")

                Spacer()
            }

            Spacer()

            // 1. 게임 상태가 unstarted면 기본적으로 연결된 사용자를 보여주는 PlayerProfileView을 띄움
            if state == .unstarted {
                // 프로필 슬롯
                PlayerProfileView(connected: connected)

                // 1-1. 그러다가 인원수가 다 차면 5초 카운트다운이 시작됨
                if connected.peers.count == P2PNetwork.maxConnectedPeers {
                    if let countdown = countdown {
                        Text("게임이 \(countdown)초 후 시작됩니다")
                            .font(.title)
                            .padding()
                    }
                } else {
                    Text("다른 플레이어를 기다리는 중입니다 (\(connected.peers.count)/\(P2PNetwork.maxConnectedPeers))")
                }
            }

            //: : 2. 게임 플레이 중에 누군가가 나가서 연결된 사람이 없으면 일단 오류 발생 버튼이 뜸.
            else if state == .pausedGame {
                Button("오류 발생. 다시 돌아가기") {
                    P2PNetwork.outSession()
                    P2PNetwork.removeAllDelegates()
                    router.currentScreen = .choosePlayer
                }

            } else {
                GameView(gameState: $state)
            }
        }
        .padding()
        .padding(.vertical, 30)
        // 프리뷰 확인 시 onAppear 주석 필요
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

struct ConnectViewPreviewWrapper: View {
    @StateObject var connected = ConnectedPeers.preview(
        peers: [
            Peer(MCPeerID(displayName: "유저 1"), id: "1"),
        ],
        host: Peer(MCPeerID(displayName: "호스트"), id: "0")
    )

    var body: some View {
        ConnectView(connected: connected)
            .environmentObject(AppRouter())
    }
}

#Preview {
    P2PNetwork.maxConnectedPeers = 3
    return ConnectViewPreviewWrapper()
}
