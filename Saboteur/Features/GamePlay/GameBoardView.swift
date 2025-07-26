import P2PKit
import SaboteurKit
import SwiftUI

struct GameBoardView: View {
    @StateObject private var boardViewModel: BoardViewModel

    @ObservedObject var winner: P2PSyncedObservable<Peer.Identifier>
    init(winner: P2PSyncedObservable<Peer.Identifier>) {
        _boardViewModel = StateObject(wrappedValue: BoardViewModel(winner: winner))
        self.winner = winner
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
            HStack(spacing: 15.5) {
                // 사용자 리스트
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(allPlayers, id: \.id) { player in
                        let isMe = player.id == P2PNetwork.myPeer.id
                        let displayText = isMe ? "나: \(player.displayName)" : player.displayName
                        let isCurrent = boardViewModel.currentPlayer.value == player.id

                        Text(displayText)
                            .padding(6)
                            .background(isCurrent ? Color.yellow.opacity(0.3) : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isCurrent ? Color.orange : Color.clear, lineWidth: 2)
                            )
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
