import P2PKit
import SaboteurKit
import SwiftUI

enum GameResult {
    case winner(String)
}

struct GameView: View {
    @Binding var gameState: GameState
    @StateObject private var viewModel = GameViewModel()

    @StateObject private var winner = P2PSyncedObservable(name: "GameWinner", initial: "")
    @StateObject private var players = P2PSyncedObservable(name: "AllPlayers", initial: [String]())

    @EnvironmentObject var router: AppRouter

    var body: some View {
        if gameState == .endGame {
            ZStack {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()

                GameResultView(result: .winner(winner.value), players: players.value, myName: P2PNetwork.myPeer.displayName)
            }
        } else {
            VStack {
                Button {
                    let remainingPeers = P2PNetwork.connectedPeers

                    if let remaining = remainingPeers.first {
                        winner.value = remaining.displayName
                    }
                    router.currentScreen = .choosePlayer

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        gameState = .endGame
                        P2PNetwork.outSession()
                    }

                } label: {
                    Text("게임 나가기")
                }

                GameBoardView(winner: winner)
                    .onChange(of: winner.value) {
                        gameState = .endGame
                    }
                    .onAppear {
                        let allDisplayNames = ([P2PNetwork.myPeer] + P2PNetwork.connectedPeers).map(\.displayName)
                        players.value = allDisplayNames.sorted()
                    }
            }
        }
    }
}

#Preview {
    GameView(gameState: .constant(.startedGame))
}

struct GameBoardView: View {
    @StateObject private var boardViewModel: BoardViewModel

    @ObservedObject var winner: P2PSyncedObservable<String>
    init(winner: P2PSyncedObservable<String>) {
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
            HStack {
                // 사용자 리스트
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(allPlayers.map(\.displayName), id: \.self) { name in
                        let isMe = name == myDisplayName
                        let displayText = isMe ? "나: \(name)" : name

                        Text(displayText)
                            .padding(6)
                            .background(boardViewModel.currentPlayer.value == name ? Color.yellow.opacity(0.3) : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(boardViewModel.currentPlayer.value == name ? Color.orange : Color.clear, lineWidth: 2)
                            )
                    }
                }

                VStack(spacing: 4) {
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(40)), count: 9), spacing: 4) {
                        ForEach(0 ..< 9 * 5, id: \.self) { index in
                            let x = index % 9
                            let y = index / 9
                            let key = "\(x),\(y)"
                            let placed = boardViewModel.placedCards.value[key]
                            let fallback = boardViewModel.board.grid[x][y]
                            let boardCell = placed ?? fallback

                            GridCellView(x: x, y: y, cell: boardCell, isCursor: boardViewModel.cursor == (x, y)) {
                                boardViewModel.cursor = (x, y)
                                boardViewModel.placeSelectedCard()
                            }
                        }
                    }

                    HStack {
                        ForEach(Array(cardSet.enumerated()), id: \.offset) { _, card in
                            Button(action: {
                                boardViewModel.selectedCard = card
                            }) {
                                Image(card.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .background(boardViewModel.selectedCard?.imageName == card.imageName ? Color.blue : Color.gray)
                                    .cornerRadius(4)
                            }
                        }
                    }
                    Text("카드를 클릭하여 위치를 선택하세요")
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

    struct GridCellView: View {
        let x: Int
        let y: Int
        let cell: BoardCell
        let isCursor: Bool
        let onTap: () -> Void

        var body: some View {
            Image(cell.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .background(isCursor ? Color.yellow : Color.clear)
                .border(Color.black)
                .onTapGesture {
                    onTap()
                }
        }
    }
}

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

    // 현재 턴인 플레이어의 이름
    @Published var currentPlayer = P2PNetwork.currentTurnPlayerName

    // 어느 플레이어가 어떤 카드를 어디에 놓았는지 공유
    @Published var placedCards = P2PSyncedObservable(name: "PlacedCards", initial: [String: BoardCell]())

    let winner: P2PSyncedObservable<String>
    init(winner: P2PSyncedObservable<String>) {
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

        if currentPlayer.value != P2PNetwork.myPeer.displayName {
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
        guard let currentIndex = sortedPlayers.firstIndex(where: { $0.displayName == currentPlayer.value }) else { return }
        let nextIndex = (currentIndex + 1) % sortedPlayers.count
        currentPlayer.value = sortedPlayers[nextIndex].displayName
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
