//
//  SaboteurApp.swift
//  Saboteur
//
//  Created by kirby on 7/9/25.
//

import Logging
import P2PKit
import SwiftData
import SwiftUI

@main
struct SaboteurApp: App {
    @StateObject private var router = AppRouter()

    // AppDelegate를 SwiftUI에 연결
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // SwiftDataContainer의 싱글톤 사용
    var sharedModelContainer: ModelContainer {
        SwiftDataContainer.shared.container
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        Group {
            switch router.currentScreen {
            case .choosePlayer: LobbyView()

            case .connect: ConnectView()

            case .none: Color.clear
            }
        }
        .task {
            P2PConstants.networkChannelName = "my-p2p-2p"
            P2PConstants.loggerEnabled = true
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppRouter())
}
