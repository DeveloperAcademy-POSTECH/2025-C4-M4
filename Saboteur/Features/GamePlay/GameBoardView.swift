import P2PKit
import SaboteurKit
import SwiftUI

struct GameBoardView: View {
    // @Binding var gameState: GameState
    @EnvironmentObject var router: AppRouter

    @StateObject private var boardViewModel: BoardViewModel

    @ObservedObject var winner: P2PSyncedObservable<Peer.Identifier>
    var exitToastMessage: P2PSyncedObservable<String>

    @State private var turnTimeRemaining: Int = 90
    @State private var turnTimer: Timer? = nil

    init(winner: P2PSyncedObservable<Peer.Identifier>, exitToastMessage: P2PSyncedObservable<String>) {
        _boardViewModel = StateObject(wrappedValue: BoardViewModel(winner: winner))
        self.winner = winner
        // _gameState = gameState
        self.exitToastMessage = exitToastMessage
    }

    private func startTurnTimer() {
        turnTimer?.invalidate()
        turnTimeRemaining = 90

        turnTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if turnTimeRemaining > 0 {
                turnTimeRemaining -= 1
            } else {
                timer.invalidate()
                turnTimer = nil

                // ⏰ 시간 초과 시 무작위 카드 제거 및 새 카드 지급
                boardViewModel.autoDiscardAndDraw()
                boardViewModel.nextTurn()
            }
        }
    }

    // 모든 플레이어 배열
    private var allPlayers: [Peer] {
        [P2PNetwork.myPeer] + P2PNetwork.connectedPeers // 나 자신 + 연결된 사람
    }

    private var myDisplayName: String {
        P2PNetwork.myPeer.displayName // 나 자신 -> '나:'를 붙이기 위함
    }

    var body: some View {
        ZStack {
            HStack(alignment: .top, spacing: 15.5) {
                VStack(alignment: .leading, spacing: 24) {
                    // 나가기 버튼
                    Button {
                        let allPeers = [P2PNetwork.myPeer] + P2PNetwork.connectedPeers
                        if allPeers.count == 2 {
                            let myID = P2PNetwork.myPeer.id
                            if let remaining = allPeers.first(where: { $0.id != myID }) {
                                winner.value = remaining.id
                            }

                            exitToastMessage.value = "\(boardViewModel.myName)님이 나가서 게임이 강제 종료되었습니다"
                        }
                        router.currentScreen = .choosePlayer

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            GameStateManager.shared.current = .endGame
                            P2PNetwork.updateGameState()
                            P2PNetwork.outSession()
                        }
                    } label: {
                        Image(.outButton)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 62)
                    }

                    // 사용자 리스트
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(allPlayers, id: \.id) { player in
                            let isMe = player.id == P2PNetwork.myPeer.id
                            // let displayText = isMe ? "나: \(player.displayName)" : player.displayName
                            let isCurrent = boardViewModel.currentPlayer.value == player.id

                            let playerName = player.displayName.split(separator: " ", maxSplits: 1).map { String($0) }
                            let flag = playerName.first ?? "🇰🇷"
                            let name = playerName.count > 1 ? playerName[1] : ""
                            let flagToIcon: [String: String] = [
                                "🇺🇸": "usa_icon", "🇧🇷": "brazil_icon", "🇮🇳": "india_icon", "🇰🇷": "korea_icon", "🇨🇳": "china_icon", "🇯🇵": "japan_icon", "🇮🇩": "indonesia_icon", "🇩🇪": "german_icon", "🇬🇧": "uk_icon", "🇹🇷": "turkey_icon", "🇲🇽": "mexico_icon",
                            ]

                            HStack(spacing: 10) {
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack {
                                        if let iconName = flagToIcon[flag] {
                                            Image(iconName)
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .overlay(
                                                    Circle()
                                                        .stroke(isCurrent ? Color.Emerald.emerald1 : Color.Ivory.ivory2, lineWidth: 2)
                                                )
                                        }

                                        Spacer()

                                        // 시간
                                        if isCurrent {
                                            let minutes = turnTimeRemaining / 60
                                            let seconds = turnTimeRemaining % 60
                                            HStack(spacing: 1) {
                                                Image(systemName: "clock.fill")
                                                    .font(.system(size: 10))

                                                Text(String(format: "%d:%02d", minutes, seconds))
                                            }
                                            .foregroundStyle(Color.Grayscale.whiteBg)
                                            .label4Font()
                                            .padding(.vertical, 2)
                                            .padding(.leading, 3)
                                            .padding(.trailing, 7)
                                            .background {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .foregroundStyle(Color.Etc.pink)
                                            }
                                        }
                                    }

                                    Text("\(name)")
                                        .foregroundStyle(isCurrent ? Color.Ivory.ivory1 : Color.Emerald.emerald1)
                                        .label5Font()
                                        .padding(.horizontal, 4)
                                        .padding(.top, 1)
                                        .padding(.bottom, 5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 3.3)
                                                .shadow4ColorInner(color: isCurrent ? Color.Emerald.emerald1 : Color.Ivory.ivory2)
                                                .foregroundStyle(isCurrent ? Color.Emerald.emerald3 : Color.Ivory.ivory1)
                                                .overlay(content: {
                                                    RoundedRectangle(cornerRadius: 3.3)
                                                        .stroke(isCurrent ? Color.Emerald.emerald1 : Color.Ivory.ivory2, lineWidth: 1)
                                                })
                                        )
                                }
                                .frame(width: 86, height: 39)
                            }
                        }
                    }
                }
                .padding(.vertical, 16)

                VStack(spacing: 4) {
                    BoardGridView(
                        board: boardViewModel.board.grid,
                        placedCards: boardViewModel.placedCards.value,
                        cursor: boardViewModel.cursor,
                        onTapCell: { x, y in
                            boardViewModel.cursor = (x, y)
                            boardViewModel.placeSelectedCard()
                        },
                        latestPlacedCoord: boardViewModel.latestPlacedCoord.value,
                        temporarilyRevealedCell: boardViewModel.revealedGoalCell
                    )
                    HStack(spacing: 24) {
                        Button(action: {
                            boardViewModel.rotateSelectedCard()
                        }, label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 100)
                                    .shadow3BlackInner()
                                    .foregroundStyle(Color.Ivory.ivory1)
                                    .frame(width: 54, height: 50)

                                Image(.turnButton)
                                    .resizable()
                                    .frame(width: 25.26, height: 29)
                                    .foregroundStyle(Color.Emerald.emerald2)
                            }
                        })

                        CardSelectionView(
                            cards: boardViewModel.getMe?.cardsInHand ?? [],
                            selectedCard: $boardViewModel.selectedCard,
                            onSelect: { card in
                                boardViewModel.selectedCard = card
                            }
                        )
                        .frame(width: 388, height: 72)

                        Button(action: {
                            boardViewModel.deleteSelectedCard()
                        }, label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .shadow3BlackInner()
                                    .foregroundStyle(Color.Ivory.ivory1)
                                    .frame(width: 54, height: 50)

                                Image(.trashButton)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32)
                                    .padding(.top, -10)
                            }
                        })
                    }
                    .frame(height: 72)

                }.padding()
                    .onReceive(boardViewModel.currentPlayer.objectWillChange) { _ in
                        boardViewModel.cursor = boardViewModel.cursor
                        let toast = boardViewModel.syncedToast.value

                        guard !toast.message.isEmpty else { return }

                        let myID = P2PNetwork.myPeer.id
                        let shouldShow: Bool = {
                            switch toast.target {
                            case .global: return true
                            case .personal: return toast.senderID == myID
                            case .other: return toast.senderID != myID
                            }
                        }()

                        if shouldShow {
                            boardViewModel.showToast(toast.message)
                        }

                        if toast.senderID == myID {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                if boardViewModel.syncedToast.value == toast {
                                    boardViewModel.syncedToast.value = TargetedToast(message: "", target: .personal, senderID: "")
                                }
                            }
                        }
                    }
                    .onChange(of: boardViewModel.placedCards.value) { _ in
                        boardViewModel.syncBoardWithPlacedCards()
                    }
            }
            .onChange(of: boardViewModel.currentPlayer.value) { _ in
                startTurnTimer()
            }
            .onAppear {
                startTurnTimer()
            }
            .onDisappear {
                turnTimer?.invalidate()
                turnTimer = nil
            }

            if let message = boardViewModel.toastMessage {
                ToastMessage(message: message, animationTrigger: boardViewModel.toastMessage)
            }
        }
        // .frame(minHeight: UIScreen.main.bounds.height - 32)
        .onChange(of: winner.value) { newValue in
            if !newValue.isEmpty {
                GameStateManager.shared.current = .endGame
            }
        }
    }
}
