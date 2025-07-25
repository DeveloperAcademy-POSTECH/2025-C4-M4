import P2PKit
import SaboteurKit
import SwiftUI

enum GameResult {
    case winner(Peer.Identifier)
}

struct GameView: View {
    @Binding var gameState: GameState
    @StateObject private var viewModel = GameViewModel()

    @StateObject private var winner = P2PSyncedObservable<Peer.Identifier>(name: "GameWinner", initial: "")
    @StateObject private var players = P2PSyncedObservable(name: "AllPlayers", initial: [String]())

    @EnvironmentObject var router: AppRouter

    var body: some View {
        if gameState == .endGame {
            ZStack {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()

                if !winner.value.isEmpty {
                    let winnerID = winner.value
                    GameResultView(
                        result: .winner(winnerID),
                        players: [P2PNetwork.myPeer] + P2PNetwork.connectedPeers,
                        myID: P2PNetwork.myPeer.id
                    )
                }
            }
        } else {
            VStack {
                GameBoardView(winner: winner as P2PSyncedObservable<Peer.Identifier>, gameState: $gameState)
                    .environmentObject(router)
                    .onChange(of: winner.value) {
                        if !winner.value.isEmpty {
                            let finalPeers = [P2PNetwork.myPeer] + P2PNetwork.connectedPeers
                            let simplifiedPeers = finalPeers.map { ["id": $0.id, "displayName": $0.displayName] }
                            UserDefaults.standard.set(simplifiedPeers, forKey: "FinalPeers")
                            gameState = .endGame
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
    GameView(gameState: .constant(.startedGame))
}
