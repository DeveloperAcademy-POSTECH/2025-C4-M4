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

    var body: some View {
        NavigationStack {
            ZStack {
                Image(.lobbyBackground)
                    .resizable()
                    .ignoresSafeArea()

                VStack {
                    HStack {
                        Spacer()

                        Button {
                            showNameModal = true
                        } label: {
                            Image(.profileButton)
                        }
                        .padding(.trailing, 30)
                    }

                    Spacer()

                    Image(.logo)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)

                    Spacer()
                        .frame(height: 42)

                    Button {
                        router.currentScreen = .choosePlayer
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 50)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .foregroundStyle(Color.Emerald.emerald2)

                            Text("게임 시작")
                                .foregroundStyle(Color.Grayscale.whiteBg)
                                .title2Font()
                        }
                    }
                    .padding(.horizontal, 250)
                    .padding(.bottom, 40)
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
                    .frame(width: 550)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 10)
                    .padding()
                }
            }
        }
    }
}

#Preview {
    LobbyView()
        .environmentObject(AppRouter())
}
