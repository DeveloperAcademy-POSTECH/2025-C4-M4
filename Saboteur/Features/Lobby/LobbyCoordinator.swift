import SwiftUI

struct LobbyCoordinator: View {
    let onGameTap: () -> Void
    let onProfileTap: () -> Void

    var body: some View {
        LobbyView(onGameTap: onGameTap, onProfileTap: onProfileTap)
    }
}
