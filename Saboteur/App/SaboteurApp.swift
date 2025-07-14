//
//  SaboteurApp.swift
//  Saboteur
//
//  Created by kirby on 7/9/25.
//

import Logging
import SwiftData
import SwiftUI

@main
struct SaboteurApp: App {
    // AppDelegate를 SwiftUI에 연결
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // SwiftDataContainer의 싱글톤 사용
    var sharedModelContainer: ModelContainer {
        SwiftDataContainer.shared.container
    }

    var body: some Scene {
        WindowGroup {
            RootCoordinator()
        }
    }
}
