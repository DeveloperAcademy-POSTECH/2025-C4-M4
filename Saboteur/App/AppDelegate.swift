import Foundation
import Logging
import P2PKit
import UIKit

// final class SyncedStore {
//    static let shared = SyncedStore()
//
//    let exitToastMessage = P2PSyncedObservable<String>(name: "ExitToastMessage", initial: "")
//    let winner = P2PSyncedObservable<Peer.Identifier>(name: "GameWinner", initial: "")
// }

/// AppDelegate는 UIKit 기반의 앱 수명주기 이벤트를 처리하는 객체입니다.
/// SwiftUI 앱에서도 `@UIApplicationDelegateAdaptor`를 통해 연결하면
/// 앱 시작, 백그라운드 진입, 푸시 알림 등록 등 다양한 시스템 이벤트를 감지할 수 있습니다.
///
/// 이 프로젝트에서는 로그 기록 및 백그라운드 타임아웃 기반 세션 종료 관리를 위해 AppDelegate를 사용합니다.
final class AppDelegate: NSObject, UIApplicationDelegate, BackgroundTaskManagerDelegate {
    func backgroundTaskManagerDidTimeout(_: BackgroundTaskManager) {
        //
    }

    // 타임아웃 정책 상수 (필요 시 한 곳에서 쉽게 변경)
//    private enum Timeout {
//        static let background: TimeInterval = 60 // 1분 후 세션 종료
//    }

    /// 앱이 처음 실행될 때 호출됩니다.
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        logNotice("✅ App started.")
        BackgroundTaskManager.shared.delegate = self
        return true
    }

    /// 앱이 활성화(포그라운드 진입)될 때 호출됩니다.
    func applicationDidBecomeActive(_: UIApplication) {
        logNotice("🚀 App became active.")
        // 혹시 남아 있는 타임아웃이 있다면 취소 (중복 호출 안전)
        BackgroundTaskManager.shared.cancelTimeoutIfNeeded()
    }

    /// 앱이 비활성화될 때 (전화 수신, 알림 표시 등) 호출됩니다.
    func applicationWillResignActive(_: UIApplication) {
        logNotice("⏸️ App will resign active.")
    }

    /// 앱이 백그라운드에 진입할 때 호출됩니다.
    func applicationDidEnterBackground(_: UIApplication) {
        logNotice("🌙 App entered background.")

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            P2PNetwork.outSession()
            logNotice("🔚 세션 종료 처리 완료.")
        }
    }

    /// 앱이 포그라운드로 복귀하기 직전에 호출됩니다.
    func applicationWillEnterForeground(_: UIApplication) {
        logNotice("🌤️ App will enter foreground.")
        // 백그라운드 타임아웃 취소 (이미 취소되어 있어도 안전)
        BackgroundTaskManager.shared.cancelTimeoutIfNeeded()
    }

    /// 앱이 종료되기 직전에 호출됩니다. (실제로는 항상 보장되지 않음)
    func applicationWillTerminate(_: UIApplication) {
        logNotice("🛑 App will terminate.")
        // 안전한 최종 정리
        endCurrentSession()
    }

    // MARK: - BackgroundTaskManagerDelegate

    // 백그라운드 이동 후 1분 동안 안 돌아오면 세션에서 나가짐
//    func backgroundTaskManagerDidTimeout(_: BackgroundTaskManager) {
//        logNotice("🔥 백그라운드 타임아웃 발생 — 세션 종료 로직 실행.")
//        endCurrentSession()
//
//        // 추가: P2P 연결 해제
//        P2PNetwork.resetSession()
//    }

    // MARK: - Private Helpers

    private func endCurrentSession() {
        // TODO: 실제 세션 종료 / 저장 / P2P 정리 로직 구현
        // 예:
        // P2PNetwork.resetSession()
        // GameSession.shared.terminate()
        // StateStore.shared.persist()
        logNotice("🔚 세션 종료 처리 완료.")
    }
}
