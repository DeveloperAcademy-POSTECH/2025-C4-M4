import P2PKit
import SaboteurKit
import SwiftUI

final class BoardViewModel: ObservableObject {
    @Published var showGameEndDialog: Bool = false
    @Published var board = Board()
    @Published var cursor: (Int, Int) = (0, 0)
    @Published var selectedCard: Card? = nil
    @Published var toastMessage: String? = nil

    @Published var currentDeck = Deck()
    @Published var players: [PeerPlayer] = []

    @Published var currentPlayer: P2PSyncedObservable<Peer.Identifier> = P2PNetwork.currentTurnPlayerID
    @Published var placedCards = P2PSyncedObservable(name: "PlacedCards", initial: [String: BoardCell]())

    let winner: P2PSyncedObservable<Peer.Identifier>

    init(winner: P2PSyncedObservable<Peer.Identifier>) {
        self.winner = winner
        setupPlayers()
        dealInitialHands()
    }

    // MARK: - 유틸

    func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if self.toastMessage == message {
                self.toastMessage = nil
            }
        }
    }

    // MARK: - 초기 세팅

    private func setupPlayers() {
        let allPeers = [P2PNetwork.myPeer] + P2PNetwork.connectedPeers
        players = allPeers.map { peer in
            PeerPlayer(peer: peer, nation: "Korean")
        }
    }

    private func dealInitialHands() {
        for index in players.indices {
            for _ in 0 ..< players[index].maxHandSize {
                players[index].drawCard(from: &currentDeck)
            }
        }
    }

    // MARK: - 카드 놓기

    func placeSelectedCard() {
        guard let card = selectedCard else {
            showToast("카드를 먼저 선택해주세요.")
            return
        }

        guard let myIndex = players.firstIndex(where: { $0.peer.id == P2PNetwork.myPeer.id }) else {
            showToast("내 플레이어 정보를 찾을 수 없습니다.")
            return
        }

        guard currentPlayer.value == players[myIndex].peer.id else {
            showToast("당신의 차례가 아닙니다.")
            return
        }

        if !players[myIndex].hand.contains(card) {
            showToast("해당 카드를 손에 들고 있지 않습니다.")
            return
        }

        let (x, y) = cursor

        if card.symbol == "💣" {
            let (success, message) = board.dropBoom(x: x, y: y)
            if success {
                let cell = BoardCell(
                    isCard: false,
                    directions: card.directions,
                    symbol: card.symbol,
                    imageName: card.imageName,
                    isConnect: card.connect,
                    contributor: currentPlayer.value
                )
                placedCards.value["\(x),\(y)"] = cell
                board.grid[x][y] = cell
                players[myIndex].discardCard(card)
                players[myIndex].drawCard(from: &currentDeck)
                nextTurn()
            }
            showToast(message)
        } else {
            let (success, message) = board.placeCard(x: x, y: y, card: card, player: currentPlayer.value)
            showToast(message)

            if success {
                let cell = BoardCell(
                    isCard: true,
                    directions: card.directions,
                    symbol: card.symbol,
                    imageName: card.imageName,
                    isConnect: card.connect,
                    contributor: currentPlayer.value
                )
                placedCards.value["\(x),\(y)"] = cell
                board.grid[x][y] = cell

                if board.grid[7][2].isCard || board.grid[8][1].isCard || board.grid[8][3].isCard {
                    if board.goalCheck() {
                        showToast("🎉 \(currentPlayer.value)가 길을 완성했습니다!")
                        winner.value = currentPlayer.value
                    }
                }

                players[myIndex].discardCard(card)
                players[myIndex].drawCard(from: &currentDeck)
                nextTurn()
            }
        }

        // MARK: - 턴 넘기기

        func nextTurn() {
            let sortedPlayers = players.sorted { $0.peer.displayName < $1.peer.displayName }
            guard let currentIndex = sortedPlayers.firstIndex(where: { $0.peer.id == currentPlayer.value }) else { return }
            let nextIndex = (currentIndex + 1) % sortedPlayers.count
            currentPlayer.value = sortedPlayers[nextIndex].peer.id
        }
    }

    func resetGame() {
        board = Board()
        cursor = (0, 0)
        selectedCard = nil
        toastMessage = nil
        showGameEndDialog = false
        currentDeck = Deck()
        setupPlayers()
        dealInitialHands()
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

    func displayMyHand() {
        if let me = getMe {
            me.display()
        }
    }

    var getMe: PeerPlayer? {
        players.first(where: { $0.peer.id == P2PNetwork.myPeer.id })
    }
}
