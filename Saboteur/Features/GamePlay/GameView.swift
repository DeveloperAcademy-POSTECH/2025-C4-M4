import P2PKit
import SwiftUI

enum GameResult {
    case winner(String)
    case draw
}

struct GameView: View {
    @Binding var gameState: GameState
    @StateObject private var viewModel = GameViewModel()

    @State private var gotoGameResult: Bool = false

//    @StateObject private var winner = P2PSyncedObservable(name: "TicTacToeWinner", initial: "")

    var body: some View {
//        if winner.value != "" {
        if gotoGameResult == true {
            GameResultView()
        } else {
            VStack {
                Text("🕹️ 게임 화면 여기다 구현~")
                    .font(.title)
                    .padding()

                Text("연결된 사람 수: \(P2PNetwork.connectedPeers.count + 1)")

                Button {
                    gotoGameResult = true
                } label: {
                    Text("게임 종료 화면")
                }
            }
        }
//        .onChange(of: winner.value) { _ in
//            gameState = .endGame
//        }
    }
}

#Preview {
    GameView(gameState: .constant(.startedGame))
}
