import P2PKit
import SwiftUI

func setupP2PKit(channel: String) {
    P2PConstants.networkChannelName = channel
    P2PConstants.loggerEnabled = true
}

struct LobbyView: View {
    @StateObject private var viewModel = LobbyViewModel()

    @EnvironmentObject var router: AppRouter
    @State private var displayName: String = P2PNetwork.myPeer.displayName

    var body: some View {
        VStack {
            NavigationStack {
                VStack(spacing: 30) {
                    Text(displayName)

                    NavigationLink("이름 설정", destination: ChangeNameView(onNameChanged: {
                        displayName = P2PNetwork.myPeer.displayName
                    }))
                    .padding()

                    Button("2인 게임") {
                        P2PNetwork.maxConnectedPeers = 1
                        P2PConstants.setGamePlayerCount(2)
                        P2PNetwork.resetSession()
                        router.currentScreen = .connect
                    }
                    Button("3인 게임") {
                        P2PNetwork.maxConnectedPeers = 2
                        P2PConstants.setGamePlayerCount(3)
                        P2PNetwork.resetSession()
                        router.currentScreen = .connect
                    }
                    Button("4인 게임") {
                        P2PNetwork.maxConnectedPeers = 3
                        P2PConstants.setGamePlayerCount(4)
                        P2PNetwork.resetSession()
                        router.currentScreen = .connect
                    }
                }
            }
        }
        .onAppear {
            displayName = P2PNetwork.myPeer.displayName
        }
    }

    //: : 나중에 적용
    func startGame(with count: Int) {
        P2PConstants.setGamePlayerCount(count)
        P2PNetwork.maxConnectedPeers = count - 1
        P2PNetwork.resetSession()
        router.currentScreen = .connect
    }
}

#Preview {
    LobbyView()
        .environmentObject(AppRouter())
}
