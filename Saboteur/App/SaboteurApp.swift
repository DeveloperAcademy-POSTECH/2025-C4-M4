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

    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("DidEnterBackground") var didBackground: Bool = false

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
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                print("앱이 백그라운드로 전환됨")
                didBackground = true
                P2PNetwork.outSession()
            case .inactive:
                print("앱이 비활성화됨")
            case .active:
                print("앱이 포그라운드 상태")
            @unknown default:
                break
            }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        Group {
            switch router.currentScreen {
            case .lobby: LobbyView()
            case .choosePlayer: ChoosePlayerView()
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
