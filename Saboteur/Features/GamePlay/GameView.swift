import P2PKit
import SaboteurKit
import SwiftUI

enum GameResult {
    case winner(Peer.Identifier)
}

struct GameView: View {
    @ObservedObject private var gameState = GameStateManager.shared

    @StateObject private var viewModel = GameViewModel()
    @StateObject private var exitToastMessage = SyncedStore.shared.exitToastMessage

    @StateObject private var winner = SyncedStore.shared.winner
    @StateObject private var players = P2PSyncedObservable(name: "AllPlayers", initial: [String]())

    @EnvironmentObject var router: AppRouter

    @State private var showToast = false

    var body: some View {
        if gameState.current == .endGame {
            ZStack {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()

                let winnerID = winner.value
                GameResultView(
                    result: .winner(winnerID),
                    players: [P2PNetwork.myPeer] + P2PNetwork.connectedPeers
                )

                if !exitToastMessage.value.isEmpty {
                    ToastMessage(message: exitToastMessage.value, animationTrigger: exitToastMessage.value)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                exitToastMessage.value = ""
                            }
                        }
                }
            }
            .onAppear {}
            .onChange(of: exitToastMessage.value) {
                if !exitToastMessage.value.isEmpty {
                    showToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        exitToastMessage.value = ""
                        showToast = false
                    }
                }
            }
        } else {
            VStack {
                Text("Treasure Island")

                GameBoardView()
                    .environmentObject(router)
                    .onChange(of: winner.value) {
                        if !winner.value.isEmpty {
                            GameStateManager.shared.current = .endGame
                            P2PNetwork.updateGameState()
                        }
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
    GameView()
}
