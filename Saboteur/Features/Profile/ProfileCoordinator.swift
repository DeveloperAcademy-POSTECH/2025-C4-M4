import SwiftUI

struct ProfileCoordinator: View {
    let onBack: () -> Void

    var body: some View {
        ProfileView(onBack: onBack)
    }
}
