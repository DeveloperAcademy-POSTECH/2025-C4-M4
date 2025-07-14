import SwiftUI

/// RootCoordinatorViewModel은 앱의 전체 네비게이션 상태를 관리하는 뷰모델입니다.
/// enum Route를 통해 현재 어떤 화면을 보여줄지를 결정하며,
/// 상태 변경은 Coordinator가 담당합니다.
final class RootCoordinatorViewModel: ObservableObject {
    enum Route {
        case lobby
        case game
        case profile
    }

    @Published var route: Route = .lobby
}

/// RootCoordinator는 앱의 시작점에서 전체 화면 전환 흐름을 제어하는 Coordinator View입니다.
/// 각각의 Route 값에 따라 해당 Coordinator를 보여줍니다.
struct RootCoordinator: View {
    @StateObject private var viewModel = RootCoordinatorViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            switch viewModel.route {
            case .lobby:
                /// 로비 화면에서 사용자 입력(탭)에 따라 route를 변경함
                LobbyCoordinator(
                    onGameTap: { viewModel.route = .game },
                    onProfileTap: { viewModel.route = .profile }
                )
            case .game:
                GameCoordinator(
                    onBack: { viewModel.route = .lobby }
                )
            case .profile:
                ProfileCoordinator(
                    onBack: { viewModel.route = .lobby }
                )
            }
        }
        /// 앱이 백그라운드, 포그라운드 등 상태가 바뀔 때마다 로그 출력
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                logInfo("🌙 ScenePhase: background")
            case .active:
                logInfo("🚀 ScenePhase: active")
            case .inactive:
                logInfo("⏸️ ScenePhase: inactive")
            @unknown default:
                logInfo("❓ ScenePhase: unknown")
            }
        }
    }
}
