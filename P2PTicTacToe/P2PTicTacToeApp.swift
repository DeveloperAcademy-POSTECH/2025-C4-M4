/*
 Make sure to add in Info.list:
 NSBonjourServices
 item 0: _my-p2p-service._tcp
 item 1: _my-p2p-service._udp

 NSLocalNetworkUsageDescription
 This application will use local networking to discover nearby devices. (Or your own custom message)

 Every device in the same room should be able to see each other, whether they're on bluetooth or wifi.
 **/

import P2PKit
import SwiftUI

@main
struct P2PKitDemoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

func setupP2PKit() {
    P2PConstants.networkChannelName = "my-p2p-service"
    P2PConstants.loggerEnabled = true
}

struct RootView: View {
    @StateObject private var router = AppRouter()
    // @StateObject private var locationManager = LocationManager()

    var body: some View {
        Group {
            TabView {
                NavigationStack {
                    switch router.currentScreen {
                    case let .gameStart(id):
                        GameStartTab()
                    case .duo:
                        DuoGameView()
                    case .triple:
                        TripleGameView()
                    case .squad:
                        SquadGameView()
                    }
                }
                .tag(0)
                .edgesIgnoringSafeArea(.top)
                .tabItem {
                    Label("Game", systemImage: "gamecontroller.fill")
                }
            }
        }
        .tint(.mint)
        .task {
            setupP2PKit()
        }
    }
}
