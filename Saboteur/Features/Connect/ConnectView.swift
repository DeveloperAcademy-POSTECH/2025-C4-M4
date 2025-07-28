//
//  ConnectView.swift
//  Saboteur
//
//  Created by 이주현 on 7/15/25.
//
import Combine
import Foundation
import MultipeerConnectivity
import P2PKit
import SwiftUI

struct ConnectView: View {
    // let id: String
    @EnvironmentObject var router: AppRouter
    @State private var cancellable: AnyCancellable? = nil
    @StateObject var connected = ConnectedPeers()
    @State private var state: GameState = .unstarted

    @State private var countdown: Int? = nil
    @State private var countdownTimer: Timer? = nil

    @State private var idleTime: TimeInterval = 0
    @State private var idleTimer: Timer? = nil
    @State private var showExitAlert: Bool = false

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
                            .shadow1BlackDrop()
                            .frame(height: 50)

                            Spacer()
                        }

                        HStack {
                            Button {
                                P2PNetwork.outSession()
                                P2PNetwork.removeAllDelegates()

                                router.currentScreen = .choosePlayer
                            } label: {
                                HeaderButton(image: Image(.backButton))
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
            P2PNetwork.setupGroupVerificationListener()
            connected.start()
            startIdleTimer()

            // ✅ 유효성 검증 완료 이벤트 구독
            cancellable = P2PNetwork.groupDidLockPublisher
                .receive(on: DispatchQueue.main)
                .sink {
                    print("📬 그룹 유효성 검증 완료 이벤트 수신")
                    if connected.peers.count == P2PNetwork.maxConnectedPeers {
                        startCountdown()
                    } else {
                        print("⚠️ 유효성 검증은 완료되었지만 아직 peer 수 부족")
                    }
                }
        }
        .onChange(of: connected.peers.count) { _, newCount in
            if newCount == P2PNetwork.maxConnectedPeers {
                print("⭐️ Peer count reached (\(newCount)). 시작 countdown.")
                startCountdown()
            } else {
                // Reset any ongoing countdown or idle timer
                countdown = nil
                countdownTimer?.invalidate()
                countdownTimer = nil
                idleTime = 0
            }
        }
        .modalOverlay(isPresented: $showExitAlert, modalView: {
            PopupView(popupText: "대기 시간이 초과되어\n인원 설정 화면으로 이동합니다.") {
                P2PNetwork.outSession()
                P2PNetwork.removeAllDelegates()
                router.currentScreen = .choosePlayer
            }
        })
        .onDisappear {
            cancellable?.cancel()
            cancellable = nil
        }
    }

    private func startCountdown() {
        print("🟢 startCountdown() 호출됨")
        countdown = 5
        countdownTimer?.invalidate()

        print("📨 그룹 검증 메시지 전송 시작")
        P2PNetwork.sendGroupVerificationMessage()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if let current = countdown, current > 1 {
                countdown = current - 1
                print("⏳ 카운트다운 진행 중: \(countdown!)초 남음")
            } else {
                timer.invalidate()
                countdownTimer = nil
                print("⏰ 카운트다운 종료됨")

                let peerCount = connected.peers.count
                let expectedCount = P2PNetwork.maxConnectedPeers
                print("👥 연결된 Peer 수: \(peerCount), 필요한 수: \(expectedCount)")
                print("🔍 currentGroupID: \(String(describing: P2PNetwork.currentGroupID))")

                if peerCount == expectedCount,
                   P2PNetwork.currentGroupID != nil
                {
                    print("✅ 그룹 유효성 검증 완료. 게임 시작")
                    P2PNetwork.makeMeHost()
                    state = .startedGame
                } else {
                    print("❌ 조건 불충족 - 게임 시작하지 않음")
                }
            }
        }
    }

    // 3분 이상 대기자가 없으면 생기는 timer
    private func startIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            idleTime += 1
            if idleTime >= 180, state == .unstarted {
                idleTimer?.invalidate()
                idleTimer = nil
                showExitAlert = true
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
