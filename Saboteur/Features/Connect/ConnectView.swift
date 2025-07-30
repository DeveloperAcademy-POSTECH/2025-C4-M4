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
    @EnvironmentObject var router: AppRouter

    @StateObject var connected = ConnectedPeers()
    @State private var countdown: Int? = nil
    @State private var countdownTimer: Timer? = nil

    @State private var idleTime: TimeInterval = 0
    @State private var idleTimer: Timer? = nil
    @State private var showExitAlert: Bool = false
    @StateObject private var winner = SyncedStore.shared.winner

    @StateObject private var exitToastMessage = SyncedStore.shared.exitToastMessage

    @Environment(\.scenePhase) private var scenePhase

    @State private var showWaitingMessage = true
    @State private var messageToggleTimer: Timer? = nil

    // ✅ 게임 상태 검증을 위한 추가
    @StateObject private var stateValidator = GameStateValidator(maxPlayers: P2PNetwork.maxConnectedPeers + 1)

    var body: some View {
        ZStack {
            Image(.background)
                .resizable()
                .ignoresSafeArea()

            VStack {
                // 1. 게임 상태가 unstarted면 기본적으로 연결된 사용자를 보여주는 PlayerProfileView을 띄움
                if GameStateManager.shared.current == .unstarted {
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
                                .frame(height: 20)
                        }
                    } else {
                        ZStack {
                            HStack {
                                Text("플레이어를 기다리는 중입니다")
                                ProgressView()
                                    .tint(Color.Emerald.emerald1)
                                Text("(\(connected.peers.count)/\(P2PNetwork.maxConnectedPeers))")
                            }
                            .opacity(showWaitingMessage ? 1 : 0)

                            Text("게임 화면에서 나가면 진행 중인 게임이 종료됩니다")
                                .opacity(showWaitingMessage ? 0 : 1)
                        }
                        .foregroundStyle(Color.Emerald.emerald1)
                        .body2Font()
                        .animation(.easeInOut(duration: 1.0), value: showWaitingMessage)
                        .frame(height: 20)
                    }

                    Spacer()

                    // ✅ 게임 상태 검증 상태 표시 (디버그용, 필요시 제거)
                    if !stateValidator.isGameStateValid, !stateValidator.validationErrors.isEmpty {
                        VStack {
                            Text("⚠️ 게임 상태 검증 오류")
                                .foregroundStyle(Color.red)
                                .font(.caption)

                            ForEach(stateValidator.validationErrors.prefix(3), id: \.self) { error in
                                Text(error)
                                    .foregroundStyle(Color.red)
                                    .font(.caption2)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                }

                //: : 2. pausedGame이 되는 순간은 명시되지 않았음. 예외처리용.
                else if GameStateManager.shared.current == .pausedGame {
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
                    GameView()
                        .onAppear {
                            print("📒 GameView loaded with state: \(GameStateManager.shared.current)")
                        }
                }
            }
        }
        // 프리뷰 확인 시 onAppear 주석 필요
        .onAppear {
            P2PNetwork.resetSession()
            connected.start()
            startIdleTimer()
            messageToggleTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                withAnimation {
                    showWaitingMessage.toggle()
                }
            }
        }
        .onDisappear {
            messageToggleTimer?.invalidate()
            messageToggleTimer = nil
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                let connectedCount = P2PNetwork.connectedPeers.count
                if connectedCount == 0, GameStateManager.shared.current == .startedGame {
                    if let storedPeers = UserDefaults.standard.array(forKey: "FinalPeers") as? [[String: String]] {
                        let others = storedPeers.filter { $0["id"] != P2PNetwork.myPeer.id }
                        if let selected = others.first, let otherID = selected["id"] {
                            winner.value = otherID
                        }
                    }
                    exitToastMessage.value = "백그라운드로 나가서 게임이 종료되었습니다"
                    GameStateManager.shared.current = .endGame
                    P2PNetwork.updateGameState()
                }
            }
        }
        .onChange(of: connected.peers.count) {
            let connectedCount = P2PNetwork.connectedPeers.count
            if connectedCount == 0, GameStateManager.shared.current == .startedGame {
                winner.value = P2PNetwork.myPeer.id
                exitToastMessage.value = "상대방이 나가서 게임이 종료되었습니다"
                GameStateManager.shared.current = .endGame
                P2PNetwork.updateGameState()
            } else if connectedCount == P2PNetwork.maxConnectedPeers, GameStateManager.shared.current == .unstarted {
                startCountdown()
            } else {
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

                    // ✅ 게임 시작 전 모든 플레이어의 초기 상태 검증
                    startGameWithValidation()

                    GameStateManager.shared.current = .startedGame
                    P2PNetwork.updateGameState()

                    let allPeers = [P2PNetwork.myPeer] + connected.peers
                    let simplifiedPeers = allPeers.map { ["id": $0.id, "displayName": $0.displayName] }
                    UserDefaults.standard.set(simplifiedPeers, forKey: "FinalPeers")
                }
            }
        }
    }

    // ✅ 게임 시작 시 초기 상태 검증
    private func startGameWithValidation() {
        let sortedPeers = ([P2PNetwork.myPeer] + connected.peers)
            .sorted { $0.id < $1.id }
            .prefix(P2PNetwork.maxConnectedPeers + 1)

        let initialSnapshot = GameStateSnapshot(
            turnNumber: 0,
            currentPlayerID: sortedPeers.first?.id ?? "",
            boardState: [:], // 빈 보드로 시작
            playerHands: Dictionary(uniqueKeysWithValues:
                sortedPeers.map { ($0.id, 5) } // 초기 손패 5장
            ),
            timestamp: Date().timeIntervalSince1970,
            senderID: P2PNetwork.myPeer.id
        )

        // 게임 시작 전 모든 플레이어의 초기 상태 검증
        stateValidator.validateGameState(snapshot: initialSnapshot)

        print("🎮 게임 시작 - 초기 상태 검증 요청 완료")
        print("   - 참여 플레이어: \(sortedPeers.map(\.displayName))")
        print("   - 첫 번째 플레이어: \(sortedPeers.first?.displayName ?? "Unknown")")
    }

    // 3분 이상 대기자가 없으면 생기는 timer
    private func startIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            idleTime += 1
            if idleTime >= 180, GameStateManager.shared.current == .unstarted {
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
