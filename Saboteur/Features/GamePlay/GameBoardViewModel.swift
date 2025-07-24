import P2PKit
import SaboteurKit
import SwiftUI

final class BoardViewModel: ObservableObject {
    @Published var showGameEndDialog: Bool = false
    @Published var board = Board()
    @Published var cursor: (Int, Int) = (0, 0)
    @Published var selectedCard: Card? = nil
    @Published var toastMessage: String? = nil

    // 모든 플레이어 배열
    private var players: [Peer] {
        [P2PNetwork.myPeer] + P2PNetwork.connectedPeers // 나 자신 + 연결된 사람
    }

    // 현재 턴인 플레이어의 ID
    @Published var currentPlayer: P2PSyncedObservable<Peer.Identifier> = P2PNetwork.currentTurnPlayerID

    // 어느 플레이어가 어떤 카드를 어디에 놓았는지 공유
    @Published var placedCards = P2PSyncedObservable(name: "PlacedCards", initial: [String: BoardCell]())

    let winner: P2PSyncedObservable<Peer.Identifier>
    init(winner: P2PSyncedObservable<Peer.Identifier>) {
        self.winner = winner
    }

    func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if self.toastMessage == message {
                self.toastMessage = nil
            }
        }
    }

    func placeSelectedCard() {
        guard let card = selectedCard else {
            showToast("카드를 먼저 선택해주세요.")
            return
        }
        let (x, y) = cursor

        if currentPlayer.value != P2PNetwork.myPeer.id {
            showToast("당신의 차례가 아닙니다.")
            return
        }

        if card.symbol == "💣" {
            let (success, message) = board.dropBoom(x: x, y: y)
            if success {
                let key = "\(x),\(y)"
                let newMove = BoardCell(
                    isCard: false,
                    directions: card.directions,
                    symbol: card.symbol,
                    imageName: card.imageName,
                    isConnect: card.connect,
                    contributor: currentPlayer.value
                )
                placedCards.value[key] = newMove

                board.grid[x][y] = newMove

                nextTurn()
            }
            showToast(message)
        } else {
            let (success, message) = board.placeCard(x: x, y: y, card: card, player: currentPlayer.value)
            showToast(message)

            if success {
                let key = "\(x),\(y)"
                let newMove = BoardCell(
                    isCard: true,
                    directions: card.directions,
                    symbol: card.symbol,
                    imageName: card.imageName,
                    isConnect: card.connect,
                    contributor: currentPlayer.value
                )
                placedCards.value[key] = newMove

                board.grid[x][y] = newMove

                if board.grid[7][2].isCard || board.grid[8][1].isCard || board.grid[8][3].isCard {
                    if board.goalCheck() {
                        showToast("🎉 \(currentPlayer.value)가 길을 완성했습니다!")
                        winner.value = currentPlayer.value
                    }
                }

                nextTurn()
            }
        }
    }

    func nextTurn() {
        let sortedPlayers = players.sorted { $0.displayName < $1.displayName }
        guard let currentIndex = sortedPlayers.firstIndex(where: { $0.id == currentPlayer.value }) else { return }
        let nextIndex = (currentIndex + 1) % sortedPlayers.count
        currentPlayer.value = sortedPlayers[nextIndex].id
    }

    func resetGame() {
        board = Board()
        cursor = (0, 0)
        selectedCard = nil
        toastMessage = nil
        showGameEndDialog = false
    }

    func syncBoardWithPlacedCards() {
        for (key, cell) in placedCards.value {
            let coords = key.split(separator: ",").compactMap { Int($0) }
            if coords.count == 2 {
                let (x, y) = (coords[0], coords[1])
                board.grid[x][y] = cell
            }
        }
    }
}
