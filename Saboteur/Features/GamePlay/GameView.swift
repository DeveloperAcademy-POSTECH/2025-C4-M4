import P2PKit
import SwiftUI

enum GameResult {
    case winner(String)
    case draw // 무승부인 상황이 없으면 삭제. 혹시 몰라 씀.
}

struct GameView: View {
    @Binding var gameState: GameState
    @StateObject private var viewModel = GameViewModel()

    @StateObject private var winner = P2PSyncedObservable(name: "GameWinner", initial: "")
    @StateObject private var players = P2PSyncedObservable(name: "AllPlayers", initial: [String]())

    @EnvironmentObject var router: AppRouter

    var body: some View {
        if gameState == .endGame {
            GameResultView(result: .winner(winner.value), players: players.value, myName: P2PNetwork.myPeer.displayName)
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
                            let cell = boardViewModel.board.grid[x][y]

                            let key = "\(x),\(y)"
                            let placed = boardViewModel.placedCards.value[key]
                            let symbolToShow = placed?.symbol ?? boardViewModel.board.grid[x][y].symbol

                            Text(symbolToShow)
                                .frame(width: 40, height: 40)
                                .background(boardViewModel.cursor == (x, y) ? Color.yellow : Color.clear)
                                .border(Color.black)
                                .onTapGesture {
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
                                Text(card.symbol)
                                    .frame(width: 30, height: 30)
                                    .background(boardViewModel.selectedCard?.symbol == card.symbol ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                            }
                        }
                    }
                    Text("카드를 클릭하여 위치를 선택하세요")
//                        // 게임 종료 다이얼로그
//                        .alert("게임 종료", isPresented: $boardViewModel.showGameEndDialog) {
//                            Button("다시 시작") {
//                                boardViewModel.resetGame()
//                            }
//                            Button("홈 화면으로") {
//                                // 예시: 홈 화면 이동 로직 (구현 필요 시 분리 가능)
//                                boardViewModel.showToast("홈 화면으로 이동합니다 (예시)")
//                            }
//                        } message: {
//                            Text("🎉 \(boardViewModel.currentPlayer.value)가 길을 완성했습니다!")
//                        }
                }
                .padding()
                .onChange(of: boardViewModel.placedCards.value) { _ in
                    boardViewModel.cursor = boardViewModel.cursor
                }
                .onReceive(boardViewModel.currentPlayer.objectWillChange) { _ in
                    boardViewModel.cursor = boardViewModel.cursor
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

final class BoardViewModel: ObservableObject {
    @Published var showGameEndDialog: Bool = false
    @Published var board = Board()
    // @Published var players = (1 ... 2).map { Player(name: "P\($0)", nation: "Korean") }
    // @Published var currentPlayerIndex = 0
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
    struct PlacedCard: Codable, Equatable {
        let symbol: String
        let player: String
    }

    @Published var placedCards = P2PSyncedObservable(name: "PlacedCards", initial: [String: PlacedCard]())

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

    // var currentPlayer: Player { players[currentPlayerIndex] }
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
                let newMove = PlacedCard(symbol: card.symbol, player: currentPlayer.value)
                placedCards.value[key] = newMove

                nextTurn()
            }
            showToast(message)
        } else {
            let (success, message) = board.placeCard(x: x, y: y, card: card, player: currentPlayer.value)
            showToast(message)
            if success {
                let key = "\(x),\(y)"
                let newMove = PlacedCard(symbol: card.symbol, player: currentPlayer.value)
                placedCards.value[key] = newMove

                if board.grid[7][2].isCard || board.grid[8][1].isCard || board.grid[8][3].isCard {
                    if board.goalCheck() {
                        showToast("🎉 \(currentPlayer.value)가 길을 완성했습니다!")
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                            self.showGameEndDialog = true
//                        }
                        winner.value = currentPlayer.value
                    }
                }
                nextTurn()
            }
        }
    }

    func nextTurn() {
        // currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        let sortedPlayers = players.sorted { $0.displayName < $1.displayName }
        guard let currentIndex = sortedPlayers.firstIndex(where: { $0.displayName == currentPlayer.value }) else { return }
        let nextIndex = (currentIndex + 1) % sortedPlayers.count
        currentPlayer.value = sortedPlayers[nextIndex].displayName
    }

    func resetGame() {
        board = Board()
        // currentPlayerIndex = 0
        cursor = (0, 0)
        selectedCard = nil
        toastMessage = nil
        showGameEndDialog = false
    }
}
