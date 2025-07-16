import P2PKit
import SwiftUI

// func setupP2PKit(channel: String) {
//    P2PConstants.networkChannelName = channel
//    P2PConstants.loggerEnabled = true
// }

struct LobbyView: View {
    @StateObject private var viewModel = LobbyViewModel()

    @EnvironmentObject var router: AppRouter
    @State private var displayName: String = P2PNetwork.myPeer.displayName

    @State private var showNameModal: Bool = false
    @State private var showPlayerModal: Bool = false

    var body: some View {
        VStack {
            NavigationStack {
                VStack(spacing: 30) {
                    Button {
                        showNameModal = true
                    } label: {
                        Text(displayName)
                    }
                    .buttonStyle(.plain)
                    .padding()
                    .border(Color.black, width: 2)

                    Button("게임 시작") {
                        showPlayerModal = true
                    }
                }
            }
        }
        .onAppear {
            displayName = P2PNetwork.myPeer.displayName

            if P2PNetwork.myPeer == nil {
                showNameModal = true
            }
        }
        .overlay {
            if showNameModal {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    ChangeNameView(isPresented: $showNameModal) {
                        displayName = P2PNetwork.myPeer.displayName
                        showNameModal = false
                    }
                    .padding()
                    .frame(maxWidth: 300)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 10)
                    .padding()
                }
            }
        }
        .overlay {
            if showPlayerModal {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    ChoosePlayerView(showPlayerModal: $showPlayerModal)
                        .frame(maxWidth: 300)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                        .padding()
                }
            }
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
