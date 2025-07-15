
import SwiftUI

struct LobbyView: View {
    @StateObject private var viewModel = LobbyViewModel()

    /// RootCoordinator에서 전달받는 화면 전환 콜백
    let onGameTap: () -> Void
    let onProfileTap: () -> Void

    var body: some View {
        VStack {
            Text("🎮 로비 화면입니다")
                .font(.title)
                .padding()
            /// 버튼을 누르면 ViewModel이 아닌 Coordinator에 알림
            Button("게임 화면으로 이동", action: onGameTap)
            Button("프로필 화면으로 이동", action: onProfileTap)
        }
        .navigationTitle("로비")
    }
}
