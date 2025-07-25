import P2PKit
import SaboteurKit
import SwiftUI

struct GameBoardView: View {
    @Binding var gameState: GameState
    @EnvironmentObject var router: AppRouter
    
    @StateObject private var boardViewModel: BoardViewModel

    @ObservedObject var winner: P2PSyncedObservable<Peer.Identifier>
    init(winner: P2PSyncedObservable<Peer.Identifier>, gameState: Binding<GameState>) {
        _boardViewModel = StateObject(wrappedValue: BoardViewModel(winner: winner))
        self.winner = winner
        self._gameState = gameState
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
            HStack {
                
                VStack {
                    // 나가기 버튼
                    Button {
                        let allPeers = [P2PNetwork.myPeer] + P2PNetwork.connectedPeers
                        if allPeers.count == 2 {
                            let myID = P2PNetwork.myPeer.id
                            if let remaining = allPeers.first(where: { $0.id != myID }) {
                                winner.value = remaining.id
                            }
                        }
                        router.currentScreen = .choosePlayer
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            gameState = .endGame
                            P2PNetwork.outSession()
                        }
                    } label: {
                        Image(.outButton)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 62)
                    }
                    
                    // 사용자 리스트
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(allPlayers, id: \.id) { player in
                            let isMe = player.id == P2PNetwork.myPeer.id
                            // let displayText = isMe ? "나: \(player.displayName)" : player.displayName
                            let isCurrent = boardViewModel.currentPlayer.value == player.id

                            let playerName = player.displayName.split(separator: " ", maxSplits: 1).map { String($0) }
                            let flag = playerName.first ?? "🇰🇷"
                            let name = playerName.count > 1 ? playerName[1] : ""
                            let flagToIcon: [String: String] = [
                                "🇺🇸": "usa_icon",
                                "🇧🇷": "brazil_icon",
                                "🇮🇳": "india_icon",
                                "🇰🇷": "korea_icon",
                                "🇨🇳": "china_icon",
                                "🇯🇵": "japan_icon",
                                "🇮🇩": "indonesia_icon",
                                "🇩🇪": "german_icon",
                                "🇬🇧": "uk_icon",
                                "🇹🇷": "turkey_icon",
                                "🇲🇽": "mexico_icon",
                            ]

                            HStack(spacing: 10) {
                                VStack(alignment: .leading, spacing: 3) {
                                    if let iconName = flagToIcon[flag] {
                                        Image(iconName)
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .overlay(
                                                Circle()
                                                    .stroke(isCurrent ? Color.Ivory.ivory2 : Color.Emerald.emerald1, lineWidth: 2)
                                            )
                                    }

                                    Text("\(name)")
                                        .foregroundStyle(isCurrent ? Color.Emerald.emerald1 : Color.Ivory.ivory1)
                                        .label5Font()
                                        .padding(.horizontal, 4)
                                        .padding(.top, 1)
                                        .padding(.bottom, 5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 3.3)
                                                .shadow4ColorInner(color: isCurrent ? Color.Ivory.ivory2 : Color.Emerald.emerald1)
                                                .foregroundStyle(isCurrent ? Color.Ivory.ivory1 : Color.Emerald.emerald3)
                                                .overlay(content: {
                                                    RoundedRectangle(cornerRadius: 3.3)
                                                        .stroke(isCurrent ? Color.Ivory.ivory2 : Color.Emerald.emerald1, lineWidth: 1)
                                                })
                                        )
                                }
                            }
    //                        .padding(6)
    //                        .background(isCurrent ? Color.yellow.opacity(0.3) : Color.clear)
    //                        .cornerRadius(8)
    //                        .overlay(
    //                            RoundedRectangle(cornerRadius: 8)
    //                                .stroke(isCurrent ? Color.orange : Color.clear, lineWidth: 2)
    //                        )
                        }
                    }
                }

                VStack(spacing: 4) {
                    BoardGridView(
                        board: boardViewModel.board.grid,
                        placedCards: boardViewModel.placedCards.value,
                        cursor: boardViewModel.cursor,
                        onTapCell: { x, y in
                            boardViewModel.cursor = (x, y)
                            boardViewModel.placeSelectedCard()
                        }
                    )

                    CardSelectionView(
                        cards: boardViewModel.getMe?.cardsInHand ?? [],
                        selectedCard: $boardViewModel.selectedCard,
                        onSelect: { card in
                            boardViewModel.selectedCard = card
                        }
                    )
                }
                .padding()
                .onReceive(boardViewModel.currentPlayer.objectWillChange) { _ in
                    boardViewModel.cursor = boardViewModel.cursor
                }
                .onChange(of: boardViewModel.placedCards.value) { _ in
                    boardViewModel.syncBoardWithPlacedCards()
                }
            }

            if let message = boardViewModel.toastMessage {
                VStack {
                    Text(message)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.black.opacity(0.75))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    Spacer()
                }
                .padding()
                .animation(.easeInOut, value: boardViewModel.toastMessage)
            }
        }
    }
}
