import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    let onBack: () -> Void

    var body: some View {
        VStack {
            Text("👤 프로필 화면입니다")
                .font(.title)
                .padding()
            Button("로비로 돌아가기", action: onBack)
        }
        .navigationTitle("프로필")
    }
}
