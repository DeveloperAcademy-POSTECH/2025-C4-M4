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

    @State private var startIsSelected: Bool = false

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
                    }
                    .customPadding(.header)
                    .ignoresSafeArea()

                    VStack(spacing: 40) {
                        Image(.logo)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width * 0.55, height: UIScreen.main.bounds.height * 0.45)

                        FooterButton(action: {
                                         router.currentScreen = .choosePlayer
                                     },
                                     title: "게임 시작")
                            .customPadding(.footer)

//                        Button {
//
//
//                            startIsSelected = true
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                startIsSelected = false
//                            }
//                        } label: {
//                            FooterButton(title: "게임 시작")
//
//                        }
                    }

                    Spacer()
//                        .frame(height: UIScreen.main.bounds.height * 0.08)
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
                    .background(Color.Ivory.ivory1)
                    .cornerRadius(16)
                    .shadow(radius: 10)
                }
            }
        }
    }
}

#Preview {
    LobbyView()
        .environmentObject(AppRouter())
}

// struct LobbyView_Preview: PreviewProvider {
//    static var devices = ["iPhone 11", "iPhone 16 Pro Max", "iPad Pro 13-inch"]
//    static var previews: some View {
//        ForEach(devices, id: \.self) { device in
//            LobbyView()
//                .environmentObject(AppRouter())
//                .previewDevice(PreviewDevice(rawValue: device))
//                .previewDisplayName(device)
//        }
//    }
// }
