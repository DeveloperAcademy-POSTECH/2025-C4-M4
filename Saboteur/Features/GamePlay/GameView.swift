import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()

    let onBack: () -> Void

    var body: some View {
        VStack {
            Text("🕹️ 게임 화면입니다")
                .font(.title)
                .padding()
            Button("로비로 돌아가기", action: onBack)
        }
        .navigationTitle("게임 플레이")
    }
}
