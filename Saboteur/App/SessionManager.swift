//
//  SessionManager.swift
//  Saboteur
//
//  Created by Baba on 7/19/25.
//

import Foundation
import Logging
import UIKit // UIBackgroundTaskIdentifier 및 UIApplication을 위해 필요

/// 애플리케이션의 세션을 관리하며, 백그라운드 타임아웃 로직을 포함합니다.
final class SessionManager: BackgroundTaskManagerDelegate {
    private let logger = Logger(label: "SessionManager")
    private let sessionTimeout: TimeInterval = 300 // 5분

    /// SessionManager를 초기화하고, BackgroundTaskManager의 델리게이트로 자신을 설정합니다.
    init() {
        BackgroundTaskManager.shared.delegate = self
        logger.info("SessionManager가 초기화되었고 BackgroundTaskManager의 델리게이트로 설정되었습니다.")
    }

    /// 애플리케이션이 백그라운드에 진입할 때 호출됩니다.
    /// 백그라운드 타임아웃 프로세스를 시작합니다.
    func applicationDidEnterBackground() {
        logger.notice("🌙 앱이 백그라운드에 진입했습니다. 세션 타임아웃을 시작합니다.")
        BackgroundTaskManager.shared.startTimeout(after: sessionTimeout)
    }

    /// 애플리케이션이 포그라운드로 진입하기 직전에 호출됩니다.
    /// 보류 중인 백그라운드 타임아웃을 취소합니다.
    func applicationWillEnterForeground() {
        logger.notice("🌤️ 앱이 포그라운드로 진입할 예정입니다. 세션 타임아웃을 취소합니다.")
        BackgroundTaskManager.shared.cancelTimeoutIfNeeded()
    }

    // MARK: - BackgroundTaskManagerDelegate

    /// BackgroundTaskManager에 의해 백그라운드 세션 타임아웃이 발생했을 때 호출됩니다.
    func backgroundTaskManagerDidTimeout(_ manager: BackgroundTaskManager) {
        logger.notice("⏰ 세션 시간이 초과되었습니다. 세션을 종료합니다.")
        // 여기에 실제 세션 종료 로직을 구현하세요.
        // 예를 들어, 로그인 화면으로 이동하거나 사용자 데이터를 지울 수 있습니다.
        // 예시: NotificationCenter.default.post(name: .sessionDidTimeout, object: nil)
        // 세션 만료를 사용자에게 알리는 UI를 표시할 수도 있습니다.
    }
}
