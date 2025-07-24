//
// BackgroundTaskManager.swift
// Saboteur
//
// Created by Baba on 7/17/25.
//

import UIKit
import Logging

/// 백그라운드 태스크 타임아웃 알림을 받기 위한 델리게이트 프로토콜입니다.
protocol BackgroundTaskManagerDelegate: AnyObject {
    /// 지정된 시간(interval)이 지난 후에도 앱이 백그라운드에 남아 있을 때 호출됩니다.
    func backgroundTaskManagerDidTimeout(_ manager: BackgroundTaskManager)
}

/// 앱이 백그라운드에 진입한 후 일정 시간 뒤에 타임아웃을 관리하는 매니저입니다.
final class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()

    // MARK: - 로거 인스턴스를 한 번만 생성하여 재사용합니다.
    private let logger = Logger(label: "AppLifecycle")

    private init() {}

    weak var delegate: BackgroundTaskManagerDelegate?

    private var bgTask: UIBackgroundTaskIdentifier = .invalid
    private var timeoutWorkItem: DispatchWorkItem?

    /// 앱이 백그라운드에 진입할 때 호출됩니다. 'interval' 초 후에 타임아웃을 트리거합니다.
    func startTimeout(after interval: TimeInterval) {
        cancelTimeoutIfNeeded()

        // 시스템 백그라운드 시간 만료 시 호출될 핸들러입니다.
        bgTask = UIApplication.shared.beginBackgroundTask(withName: "SessionTimeout") { [weak self] in
            self?.logger.notice("⏳ 시스템에 의해 백그라운드 태스크 시간이 만료되었습니다. 타임아웃을 트리거합니다.")
            self?.triggerTimeout()
        }

        // 개발자가 지정한 'interval' 시간 후에 호출될 핸들러입니다.
        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.logger.notice("⏱️ 사용자 지정 시간이 만료되었습니다. 타임아웃을 트리거합니다.")
            self.triggerTimeout()
        }
        timeoutWorkItem = work
        DispatchQueue.global().asyncAfter(deadline: .now() + interval, execute: work)
    }

    /// 앱이 포그라운드로 복귀할 때 호출됩니다. 예약된 태스크를 취소하고 백그라운드 태스크를 종료합니다.
    func cancelTimeoutIfNeeded() {
        timeoutWorkItem?.cancel()
        timeoutWorkItem = nil

        if bgTask != .invalid {
            UIApplication.shared.endBackgroundTask(bgTask)
            bgTask = .invalid
            logger.notice("✅ 백그라운드 태스크가 취소되고 종료되었습니다.")
        }
    }

    /// 실제 타임아웃 발생을 처리합니다: 델리게이트에게 알리고, 로깅하고, 정리합니다.
    private func triggerTimeout() {
        // 이 블록은 메인 스레드에서 실행되어야 합니다 (UI 업데이트, 델리게이트 알림 등).
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.backgroundTaskManagerDidTimeout(self)
            self.logger.notice("🛑 백그라운드 타임아웃 발생 — 델리게이트에게 알림.")
            self.cancelTimeoutIfNeeded() // 타임아웃 발생 후 정리
        }
    }
}
