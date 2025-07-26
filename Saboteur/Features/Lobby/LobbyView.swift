import P2PKit
import SwiftUI

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
                            HeaderButton(image: Image(.profileButton))
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
                    }

                    Spacer()
                }
            }
        }
        .onAppear {
            displayName = P2PNetwork.myPeer.displayName.trimmingCharacters(in: .whitespacesAndNewlines)

            if displayName.isEmpty || displayName.starts(with: "TEMP_USER_") {
                showNameModal = true
            }
        }
        .modalOverlay(isPresented: $showNameModal) {
            ChangeNameView(isPresented: $showNameModal) {
                displayName = P2PNetwork.myPeer.displayName
                showNameModal = false
            }
        }
    }
}
