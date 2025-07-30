import Combine
import P2PKit
import SaboteurKit
import SwiftUI

final class BoardViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var showGameEndDialog: Bool = false
    @Published var board: Board = .init(goalIndex: 0)
    @Published var cursor: (Int, Int) = (0, 0)
    @Published var selectedCard: Card? = nil
    @Published var toastMessage: String? = nil

    @Published var currentDeck = Deck()
    @Published var players: [PeerPlayer] = []

    @Published var currentPlayer: P2PSyncedObservable<Peer.Identifier> = P2PNetwork.currentTurnPlayerID
    @Published var placedCards = P2PSyncedObservable(name: "PlacedCards", initial: [Coordinate: BoardCell]())
    @Published var revealedGoalCell: (x: Int, y: Int)? = nil

    let latestPlacedCoord = P2PSyncedObservable<Coordinate?>(name: "LatestCoord", initial: nil)

    let syncedToast = P2PSyncedObservable<TargetedToast>(
        name: "SyncedToastMessage",
        initial: TargetedToast(message: "", target: .personal, senderID: "")
    )
    private var cancellables = Set<AnyCancellable>()
    let syncedGoalIndex: P2PSyncedObservable<Int> = P2PSyncedObservable(
        name: "GoalIndex",
        initial: -1
    )

    let winner = SyncedStore.shared.winner

    private var discardCooldown = false

    init() {
        setupPlayers()
        dealInitialHands()

        if defautPeer.isMe {
            syncedGoalIndex.value = Int.random(in: 0 ..< 3)
            print("🎲 나는 호스트이며 goalIndex는 \(syncedGoalIndex.value)")
        }
        // ✅ goalIndex가 호스트로부터 전달되었을 때 보드 재설정
        syncedGoalIndex.objectWillChange
            .sink { [weak self] in
                guard let self = self else { return }
                let newIndex = self.syncedGoalIndex.value
                guard (0 ..< 3).contains(newIndex) else { return }

                self.board = Board(goalIndex: newIndex)
                print("📦 클라이언트에서 goalIndex 수신 및 보드 재생성: \(newIndex)")
            }
            .store(in: &cancellables)
    }

    // MARK: - 토스트 메시지

    /// 로컬 전용 토스트 메시지 표시 (global 전파 안 함)
    func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            if self.toastMessage == message {
                self.toastMessage = nil
            }
        }
    }

    /// 글로벌 toast 전송
    func sendToast(_ message: String, target: ToastTarget) {
        let toast = TargetedToast(
            message: message,
            target: target,
            senderID: P2PNetwork.myPeer.id
        )
        syncedToast.value = toast
    }
}
