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

    var body: some View {
        if gameState == .endGame {
            GameResultView(result: .winner(winner.value), players: players.value, myName: P2PNetwork.myPeer.displayName)
        } else {
            ZStack(alignment: .topTrailing) {
                Button {
                    winner.value = "플레이어 1"
                    gameState = .endGame
                } label: {
                    Text("게임 종료 화면")
                }
                GameBoardView().onChange(of: winner.value) {
                    gameState = .endGame
                }
            }
        }
    }
}

#Preview {
    GameView(gameState: .constant(.startedGame))
}

struct GameBoardView: View {
    @StateObject private var boardViewModel = BoardViewModel()

    var body: some View {
        ZStack {
            VStack(spacing: 4) {
                Text("현재 플레이어: \(boardViewModel.currentPlayer.name)")
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(40)), count: 9), spacing: 4) {
                    ForEach(0 ..< 9 * 5, id: \.self) { index in
                        let x = index % 9
                        let y = index / 9
                        let cell = boardViewModel.board.grid[x][y]
                        Text(cell.symbol)
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

                    // 게임 종료 다이얼로그
                    .alert("게임 종료", isPresented: $boardViewModel.showGameEndDialog) {
                        Button("다시 시작") {
                            boardViewModel.resetGame()
                        }
                        Button("홈 화면으로") {
                            // 예시: 홈 화면 이동 로직 (구현 필요 시 분리 가능)
                            boardViewModel.showToast("홈 화면으로 이동합니다 (예시)")
                        }
                    } message: {
                        Text("🎉 \(boardViewModel.currentPlayer.name)가 길을 완성했습니다!")
                    }
            }
            .padding()

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
    @Published var players = (1 ... 2).map { Player(name: "P\($0)", nation: "Korean") }
    @Published var currentPlayerIndex = 0
    @Published var cursor: (Int, Int) = (0, 0)
    @Published var selectedCard: Card? = nil
    @Published var toastMessage: String? = nil

    func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if self.toastMessage == message {
                self.toastMessage = nil
            }
        }
    }

    var currentPlayer: Player { players[currentPlayerIndex] }

    func placeSelectedCard() {
        guard let card = selectedCard else {
            showToast("카드를 먼저 선택해주세요.")
            return
        }
        let (x, y) = cursor

        if card.symbol == "💣" {
            let (success, message) = board.dropBoom(x: x, y: y)
            if success {
                nextTurn()
            }
            showToast(message)
        } else {
            let (success, message) = board.placeCard(x: x, y: y, card: card, player: currentPlayer.name)
            showToast(message)
            if success {
                if board.grid[7][2].isCard || board.grid[8][1].isCard || board.grid[8][3].isCard {
                    if board.goalCheck() {
                        showToast("🎉 \(currentPlayer.name)가 길을 완성했습니다!")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.showGameEndDialog = true
                        }
                    }
                }
                nextTurn()
            }
        }
    }

    func nextTurn() {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
    }

    func resetGame() {
        board = Board()
        currentPlayerIndex = 0
        cursor = (0, 0)
        selectedCard = nil
        toastMessage = nil
        showGameEndDialog = false
    }
}
