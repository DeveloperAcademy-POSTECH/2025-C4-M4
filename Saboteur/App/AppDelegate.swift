import Logging
import UIKit

/// AppDelegate는 UIKit 기반의 앱 수명주기 이벤트를 처리하는 객체입니다.
/// SwiftUI 앱에서도 `@UIApplicationDelegateAdaptor`를 통해 연결하면
/// 앱 시작, 백그라운드 진입, 푸시 알림 등록 등 다양한 시스템 이벤트를 감지할 수 있습니다.
///
/// 이 프로젝트에서는 로그 기록을 위해 AppDelegate를 사용하고 있으며,
/// 향후 푸시 알림, 외부 URL 열기, 멀티태스킹 대응 등의 확장도 가능합니다.
final class AppDelegate: NSObject, UIApplicationDelegate {
    /// 앱이 처음 실행될 때 호출됩니다.
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        logNotice("✅ App started.")
        return true
    }

    /// 앱이 활성화(포그라운드 진입)될 때 호출됩니다.
    func applicationDidBecomeActive(_: UIApplication) {
        logNotice("🚀 App became active.")
    }

    /// 앱이 비활성화될 때 (예: 전화 수신, 알림 표시 등) 호출됩니다.
    func applicationWillResignActive(_: UIApplication) {
        logNotice("⏸️ App will resign active.")
    }

    /// 앱이 백그라운드에 진입할 때 호출됩니다.
    func applicationDidEnterBackground(_: UIApplication) {
        logNotice("🌙 App entered background.")
    }

    /// 앱이 포그라운드로 복귀하기 직전에 호출됩니다.
    func applicationWillEnterForeground(_: UIApplication) {
        logNotice("🌤️ App will enter foreground.")
    }

    /// 앱이 종료되기 직전에 호출됩니다. (대부분 백그라운드 상태에서 종료되므로 자주 호출되지 않음)
    func applicationWillTerminate(_: UIApplication) {
        logNotice("🛑 App will terminate.")
    }
}
