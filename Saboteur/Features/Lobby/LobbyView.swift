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
            VStack {
                HStack {
                    Spacer()

                    Button {
                        showNameModal = true
                    } label: {
                        Text(displayName)
                    }
                    .buttonStyle(.plain)
                    .padding()
                    .border(Color.black, width: 2)
                }

                Spacer()

                Text("Treasure Island")
                    .font(.title)

                Spacer()

                Button("게임 시작") {
                    router.currentScreen = .choosePlayer
                }
            }
            .padding()
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
