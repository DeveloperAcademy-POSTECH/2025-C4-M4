import Logging
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {

    private let logger = Logger(label: "AppLifecycle")
    private var sessionManager: SessionManager? // SessionManager 인스턴스를 강하게 참조합니다.

    private func logNotice(_ message: Logger.Message) {
        logger.notice(message)
    }

    /// 애플리케이션이 실행을 마쳤을 때 호출됩니다.
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        logNotice("✅ 앱이 시작되었습니다.")
        // SessionManager를 초기화합니다. SessionManager는 BackgroundTaskManager의 델리게이트로 자신을 설정할 것입니다.
        sessionManager = SessionManager()
        return true
    }

    /// 애플리케이션이 활성화(포그라운드 진입)될 때 호출됩니다.
    func applicationDidBecomeActive(_: UIApplication) {
        logNotice("🚀 앱이 활성화되었습니다.")
    }

    /// 애플리케이션이 비활성화되기 직전에 호출됩니다 (예: 전화 수신, 알림).
    func applicationWillResignActive(_: UIApplication) {
        logNotice("⏸️ 앱이 비활성화될 예정입니다.")
    }

    /// 애플리케이션이 백그라운드에 진입할 때 호출됩니다.
    func applicationDidEnterBackground(_: UIApplication) {
        // 백그라운드 진입 로직을 SessionManager에게 위임합니다.
        sessionManager?.applicationDidEnterBackground()
    }

    /// 애플리케이션이 포그라운드로 진입하기 직전에 호출됩니다.
    func applicationWillEnterForeground(_: UIApplication) {
        // 포그라운드 진입 로직을 SessionManager에게 위임합니다.
        sessionManager?.applicationWillEnterForeground()
    }

    /// 애플리케이션이 종료되기 직전에 호출됩니다. (앱이 백그라운드에 있을 경우 거의 호출되지 않습니다)
    func applicationWillTerminate(_: UIApplication) {
        logNotice("🛑 앱이 종료될 예정입니다.")
    }
}
