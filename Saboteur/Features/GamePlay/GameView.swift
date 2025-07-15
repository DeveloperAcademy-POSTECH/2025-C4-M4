import P2PKit
import SwiftUI

enum GameResult {
    case winner(String)
    case draw
}

struct GameView: View {
    @Binding var gameState: GameState
    @StateObject private var viewModel = GameViewModel()

    @StateObject private var winner = P2PSyncedObservable(name: "GameWinner", initial: "")

    var body: some View {
        if gameState == .endGame {
            GameResultView(result: .winner(winner.value))
        } else {
            VStack(spacing: 30) {
                Text("🕹️ 게임 화면 여기다 구현~")
                    .font(.title)
                    .padding()

                Text("연결된 사람 수: \(P2PNetwork.connectedPeers.count + 1)")

                Button {
                    winner.value = "플레이어 1"
                    gameState = .endGame
                } label: {
                    Text("게임 종료 화면")
                }
            }
            .onChange(of: winner.value) { _ in
                gameState = .endGame
            }
        }
    }
}

#Preview {
    GameView(gameState: .constant(.startedGame))
}
