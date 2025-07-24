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

    // 프리뷰를 볼때 init 실행해야 함
//    init(connected: ConnectedPeers = ConnectedPeers()) {
//        _connected = StateObject(wrappedValue: connected)
//    }

    var body: some View {
        ZStack {
            Image(.background)
                .resizable()
                .ignoresSafeArea()

            VStack {
                // 1. 게임 상태가 unstarted면 기본적으로 연결된 사용자를 보여주는 PlayerProfileView을 띄움
                if state == .unstarted {
                    // 상단 헤더
                    ZStack(alignment: .bottom) {
                        HStack {
                            Spacer()

                            StrokedText(
                                text: "\(P2PNetwork.maxConnectedPeers + 1)인 대기방",
                                strokeWidth: 9,
                                strokeColor: .white,
                                foregroundColor: UIColor(Color.Emerald.emerald2),
                                font: UIFont(name: "MaplestoryOTFBold", size: 33)!,
                                numberOfLines: 1,
                                kerning: 0,
                                // lineHeight: 10,
                                textAlignment: .center
                            )
                            .blackdropShadow()
                            .frame(height: 50)

                            Spacer()
                        }

                        HStack {
                            Button {
                                P2PNetwork.outSession()
                                P2PNetwork.removeAllDelegates()

                                router.currentScreen = .choosePlayer
                            } label: {
                                Image(.backButton)
                            }

                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .customPadding(.header)
                    .ignoresSafeArea()

                    Spacer()

                    // 프로필 슬롯
                    HStack {
                        Spacer()
                        PlayerProfileView(connected: connected)
                        Spacer()
                    }
                    .customPadding(.header)
                    .ignoresSafeArea()

                    Spacer()

                    // 1-1. 그러다가 인원수가 다 차면 5초 카운트다운이 시작됨
                    if connected.peers.count == P2PNetwork.maxConnectedPeers {
                        if let countdown = countdown {
                            Text("게임이 \(countdown)초 후 시작됩니다")
                                .foregroundStyle(Color.Emerald.emerald1)
                                .body2Font()
                                .padding()
                        }
                    } else {
                        HStack {
                            Text("플레이어를 기다리는 중입니다")
                            ProgressView()
                                .tint(Color.Emerald.emerald1)
                            Text("(\(connected.peers.count)/\(P2PNetwork.maxConnectedPeers))")
                        }
                        .foregroundStyle(Color.Emerald.emerald1)
                        .body2Font()
                    }

                    Spacer()
                }

                //: : 2. pausedGame이 되는 순간은 명시되지 않았음. 예외처리용.
                else if state == .pausedGame {
                    Button {
                        P2PNetwork.outSession()
                        P2PNetwork.removeAllDelegates()
                        router.currentScreen = .choosePlayer
                    } label: {
                        Text("오류 발생. 다시 돌아가기")
                            .foregroundStyle(Color.Emerald.emerald1)
                            .body2Font()
                    }

                } else {
                    GameView(gameState: $state)
                }
            }
        }
        // 프리뷰 확인 시 onAppear 주석 필요
        .onAppear {
            P2PNetwork.resetSession()
            connected.start()
        }
        .onChange(of: connected.peers.count) {
            let connectedCount = connected.peers.count
            if connectedCount == 0, state == .startedGame {
                state = .endGame
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
            Peer(MCPeerID(displayName: "🇰🇷 WWWWWWWW"), id: "1"),
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
