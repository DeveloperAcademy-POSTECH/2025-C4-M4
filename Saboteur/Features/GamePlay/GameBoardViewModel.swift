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
    @Published var placedCards = P2PSyncedObservable(name: "PlacedCards", initial: [String: BoardCell]())
    @Published var revealedGoalCell: (x: Int, y: Int)? = nil

    let latestPlacedCoord = P2PSyncedObservable<Coordinate?>(name: "LatestCoord", initial: nil)

    let syncedToast = P2PSyncedObservable<TargetedToast>(
        name: "SyncedToastMessage",
        initial: TargetedToast(message: "", target: .personal, senderID: "")
    )
    private var cancellables = Set<AnyCancellable>()
    let syncedGoalIndex: P2PSyncedObservable<Int> = P2PSyncedObservable(
        name: "GoalIndex",
        initial: P2PNetwork.isHost ? Int.random(in: 0 ..< 3) : -1
    )

    let winner = SyncedStore.shared.winner

    init() {
        setupPlayers()
        dealInitialHands()

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

        if P2PNetwork.isHost {
            print("🎲 나는 호스트이며 goalIndex는 \(syncedGoalIndex.value)")
        }
    }

    // MARK: - 유틸리티 메서드

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

    /// 현재 플레이어(나)의 인덱스 반환
    var getMeIndex: Int? {
        players.firstIndex(where: { $0.peer.id == P2PNetwork.myPeer.id })
    }

    /// 현재 플레이어(나)의 PeerPlayer 객체 반환
    var getMe: PeerPlayer? {
        players.first(where: { $0.peer.id == P2PNetwork.myPeer.id })
    }

    var myName: String {
        getMe?.peer.displayName ?? "Anonymous"
    }

    // MARK: - 초기화

    /// 연결된 Peer를 기반으로 플레이어 목록 구성
    private func setupPlayers() {
        let allPeers = [P2PNetwork.myPeer] + P2PNetwork.connectedPeers
        // 고유 ID 기준으로 정렬
        let sortedPeers = allPeers.sorted { $0.id < $1.id }
        players = sortedPeers.map { PeerPlayer(peer: $0, nation: "Korean") }
        currentPlayer.value = sortedPeers.first?.id ?? P2PNetwork.myPeer.id
        winner.value = ""
    }

    /// 각 플레이어에게 초기 손패 지급
    private func dealInitialHands() {
        for index in players.indices {
            for _ in 0 ..< players[index].maxHandSize {
                players[index].drawCard(from: &currentDeck)
            }
        }
    }

    // MARK: - 카드 관련 로직

    /// 카드 유효성 검사
    private func validateSelectedCard() -> (Card, Int)? {
        guard let myIndex = getMeIndex else {
            print("내 플레이어 정보를 찾을 수 없습니다.")
            return nil
        }

        guard currentPlayer.value == players[myIndex].peer.id else {
            showToast("상대방의 차례입니다")
            return nil
        }

        guard let card = selectedCard else {
            showToast("카드를 선택해주세요")
            return nil
        }

        guard players[myIndex].hand.contains(card) else {
            print("해당 카드를 손에 들고 있지 않습니다.")
            return nil
        }

        return (card, myIndex)
    }

    /// 현재 선택된 카드를 보드에 놓기
    func placeSelectedCard() {
        guard let (card, myIndex) = validateSelectedCard() else { return }

        // 추가: 카드 타입 확인
        guard CardType.allCases.contains(card.type) else {
            print("⚠️ 유효하지 않은 카드입니다.")
            print("🧨 카드 타입이 유효하지 않음: \(card)")
            return
        }

        let (x, y) = cursor
        if card.type == .bomb {
            handleBombCard(card, at: (x, y), playerIndex: myIndex)
        } else if card.type == .map {
            handleMapCard(card, at: (x, y), playerIndex: myIndex)
        } else {
            handleNormalCard(card, at: (x, y), playerIndex: myIndex)
        }
    }

    /// 맵 카드 처리
    private func handleMapCard(_ card: Card, at pos: (Int, Int), playerIndex: Int) {
        let (x, y) = pos
        guard board.isGoalLine(x: x, y: y),
              let isGoal = board.grid[x][y].isGoal
        else {
            showToast("망원경 카드는 목적지 카드에 사용할 수 있습니다")
            return
        }

        // 1. 나만 보는 UI 업데이트
        // ✅ 보여줄 좌표 설정
        revealedGoalCell = (x, y)

        // ✅ 2초 뒤에 감추기
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.revealedGoalCell = nil
        }

        // 2. 나를 제외한 모두에게 알림
        let myName = P2PNetwork.myPeer.displayName
        sendToast("\(myName)님이 망원경 카드를 사용했습니다", target: .other)

        removeCardAndDrawNew(for: playerIndex, card: card)
        nextTurn()
    }

    /// 폭탄 카드 처리
    private func handleBombCard(_ card: Card, at pos: (Int, Int), playerIndex: Int) {
        let (success, message) = board.dropBoom(x: pos.0, y: pos.1)
        showToast(message)
        if success == true { sendToast("/(myName)님이 먹구름 카드로 길을 없앴습니다", target: .other) }
        guard success else { return }

        updateCell(at: pos, with: card, isCard: false)
        removeCardAndDrawNew(for: playerIndex, card: card)
        nextTurn()
    }

    /// 일반 카드 처리
    private func handleNormalCard(_ card: Card, at pos: (Int, Int), playerIndex: Int) {
        let (success, message) = board.placeCard(x: pos.0, y: pos.1, card: card, player: myName)
        if success == false { showToast(message) }
        guard success else { return }

        // 1) 로컬 보드에 카드 반영
        updateCell(at: pos, with: card, isCard: true)

        // 2) 인접한 goal 카드(진짜/가짜) 공개 및 동기화
        if board.adjacentCheckAndFindLoad() {
            syncGoalOpenStates()
        }

        // 3) 전체 경로 완성(진짜) 여부 확인
        checkGoalCompletion()

        // 4) 손패 교체 및 턴 종료
        removeCardAndDrawNew(for: playerIndex, card: card)
        nextTurn()
    }

    /// 공개된 goal 셀(isOpened = true) 상태를 P2P로 전파
    private func syncGoalOpenStates() {
        for (gx, gy) in Board.goalPositions {
            let cell = board.grid[gx][gy]
            if cell.isOpened == true {
                placedCards.value["\(gx),\(gy)"] = cell
            }
        }
    }

    /// 보드 셀 업데이트
    private func updateCell(at pos: (Int, Int), with card: Card, isCard _: Bool) {
        let cell = BoardCell(type: card.type, contributor: currentPlayer.value)

        placedCards.value["\(pos.0),\(pos.1)"] = cell
        board.grid[pos.0][pos.1] = cell

        latestPlacedCoord.value = Coordinate(x: pos.0, y: pos.1)
    }

    /// 카드 폐기 후 새 카드 뽑기
    private func removeCardAndDrawNew(for index: Int, card: Card) {
        players[index].discardCard(card)
        players[index].drawCard(from: &currentDeck)
    }

    /// ⏰ 시간 초과 시 무작위 카드 제거 및 새 카드 뽑기
    func autoDiscardAndDraw() {
        guard let myIndex = getMeIndex else {
            print("내 정보를 찾을 수 없습니다.")
            return
        }

        let myHand = players[myIndex].cardsInHand
        guard !myHand.isEmpty else {
            print("손패가 비어있습니다.")
            return
        }

        // 무작위 카드 제거
        let randomIndex = Int.random(in: 0 ..< myHand.count)
        let discardedCard = players[myIndex].removeCard(at: randomIndex)

        // 새 카드 지급
        players[myIndex].drawCard(from: &currentDeck)

        showToast("시간이 초과되어 무작위로 카드를 버리고 새로 뽑았습니다")
        sendToast("\(myName)님의 시간이 초과되어 무작위로 카드를 버리고 새로 뽑았습니다", target: .other)
    }

    /// 도착지 세 곳(G0, G1, G2) 중 하나라도 카드가 설치되었는지 확인하는 유틸 함수
    ///
    /// 해당 위치에 카드가 놓였다는 것은 경로가 도착지 근처까지 연결되었음을 의미
    private func hasAnyGoalEntryCard() -> Bool {
        for (gx, gy) in Board.goalPositions {
            let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)] // 상하좌우

            for (dx, dy) in directions {
                let nx = gx + dx
                let ny = gy + dy

                // 보드 범위 체크
                guard board.isValidPosition(x: nx, y: ny) else { continue }

                let neighbor = board.grid[nx][ny]
                if neighbor.type?.connect ?? false {
                    return true
                }
            }
        }
        return false
    }

    /// 길 완성 여부 확인
    private func checkGoalCompletion() {
        guard hasAnyGoalEntryCard() else { return }

        let isCompleted = board.goalCheck()

        // Goal 카드 이미지 전환을 반영할 수 있도록 일단 동기 UI 업데이트
        if isCompleted {
            // 1) 모든 goal 카드 로컬에 공개
            board.revealAllGoals()
            // -> @Published board 갱신
            board = board

            // 2) 공개된 goal 카드 정보를 P2P로 전파
            syncGoalOpenStates()

            // 3) 토스트 알림let myName = getMe?.peer.displayName ?? "Anonymous"
            sendToast("🎉 \(myName)가 길을 완성했습니다!", target: .global)

            // 4) n초 후 승패 동기화
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.winner.value = P2PNetwork.myPeer.id
            }
        }
    }

    /// 선택한 카드 회전
    func rotateSelectedCard() {
        guard let card = selectedCard else {
            showToast("카드를 선택해주세요")
            return
        }
        guard let myIndex = getMeIndex else {
            print("내 정보를 찾을 수 없습니다.")
            return
        }
        guard let handIndex = players[myIndex].cardsInHand.firstIndex(of: card) else {
            // 선택했던 카드가 보드에 놓여져 있을 때
            showToast("카드를 선택해주세요")
            return
        }

        var rotatedCard = card
        rotatedCard.rotate180()
        players[myIndex].replaceCard(at: handIndex, with: rotatedCard)
        selectedCard = rotatedCard

        showToast("카드가 회전되었습니다.")
    }

    /// 선택한 카드 삭제 후 새 카드 뽑기
    func deleteSelectedCard() {
        guard let (card, myIndex) = validateSelectedCard() else { return }
        if players[myIndex].discardCard(card) {
            players[myIndex].drawCard(from: &currentDeck)
            selectedCard = nil
            sendToast("\(myName)님이 카드를 버리고 새로 뽑았습니다", target: .other)
            showToast("카드를 버리고 새로 뽑았습니다")
            nextTurn()
        } else {
            showToast("카드를 선택해주세요")
        }
    }

    // MARK: - 턴 관리

    /// 다음 플레이어로 턴 넘기기
    func nextTurn() {
        let players = self.players
        guard let currentIndex = players.firstIndex(where: { $0.peer.id == currentPlayer.value }) else { return }
        currentPlayer.value = players[(currentIndex + 1) % players.count].peer.id
    }

    // MARK: - 보드 동기화 및 리셋

    /// 게임 리셋
    func resetGame() {
        if P2PNetwork.isHost {
            syncedGoalIndex.value = Int.random(in: 0 ..< 3)
        }
        board = Board(goalIndex: syncedGoalIndex.value)

        cursor = (0, 0)
        selectedCard = nil
        toastMessage = nil
        showGameEndDialog = false
        currentDeck = Deck()
        setupPlayers()
        dealInitialHands()
    }

    /// P2P 동기화된 카드 배치를 로컬 보드에 반영
    func syncBoardWithPlacedCards() {
        for (key, cell) in placedCards.value {
            let coords = key.split(separator: ",").compactMap { Int($0) }
            guard coords.count == 2 else { continue }
            board.grid[coords[0]][coords[1]] = cell
        }
    }

    /// 카드 인덱스로 폐기 후 새 카드 뽑기
    func discardCard(at index: Int) {
        guard let myIndex = getMeIndex else {
            print("내 정보를 찾을 수 없습니다.")
            return
        }

        guard players[myIndex].removeCard(at: index) != nil else {
            print("카드 제거 실패")
            return
        }

        players[myIndex].drawCard(from: &currentDeck)
        selectedCard = nil
        print("카드를 제거하고 새로 뽑았습니다.")
    }
}
