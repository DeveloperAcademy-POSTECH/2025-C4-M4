import SwiftUI

struct GameCoordinator: View {
    let onBack: () -> Void

    var body: some View {
        GameView(onBack: onBack)
    }
}
