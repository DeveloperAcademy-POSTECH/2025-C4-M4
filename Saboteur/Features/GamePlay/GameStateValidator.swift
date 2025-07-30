// MARK: - Import statements

import Foundation
import MultipeerConnectivity
import P2PKit
import SaboteurKit
import SwiftUI

// MARK: - 1. 게임 상태 검증을 위한 새로운 구조체

public struct GameStateSnapshot: Codable, Equatable {
    let turnNumber: Int
    let currentPlayerID: Peer.Identifier
    let boardState: [String: String] // Coordinate -> BoardCell의 간소화된 버전
    let playerHands: [Peer.Identifier: Int] // 각 플레이어 손패 수만 저장
    let timestamp: TimeInterval
    let senderID: Peer.Identifier

    static func current(from viewModel: BoardViewModel) -> GameStateSnapshot {
        // BoardCell을 간단한 String으로 변환하여 Codable 지원
        let simplifiedBoardState = viewModel.placedCards.value.reduce(into: [String: String]()) { result, item in
            let coordKey = "\(item.key.x),\(item.key.y)"
            let cellValue = item.value.type?.rawValue ?? "empty"
            result[coordKey] = cellValue
        }

        return GameStateSnapshot(
            turnNumber: viewModel.turnNumber,
            currentPlayerID: viewModel.currentPlayer.value,
            boardState: simplifiedBoardState,
            playerHands: Dictionary(uniqueKeysWithValues:
                viewModel.players.map { ($0.peer.id, $0.cardsInHand.count) }
            ),
            timestamp: Date().timeIntervalSince1970,
            senderID: P2PNetwork.myPeer.id
        )
    }
}

// MARK: - 2. 게임 액션 검증을 위한 프로토콜

public protocol GameAction: Codable {
    var actionID: String { get }
    var playerID: Peer.Identifier { get }
    var timestamp: TimeInterval { get }
    var turnNumber: Int { get }
}

public struct CardPlaceAction: GameAction, Codable {
    public let actionID = UUID().uuidString
    public let playerID: Peer.Identifier
    public let timestamp: TimeInterval
    public let turnNumber: Int

    let coordinate: Coordinate
    let cardType: String // CardType.rawValue로 저장
    let cardRotation: Int

    enum CodingKeys: String, CodingKey {
        case actionID, playerID, timestamp, turnNumber
        case coordinate, cardType, cardRotation
    }
}

// MARK: - 3. 데이터 검증 매니저

public class GameStateValidator: ObservableObject {
    private let validationService = P2PEventService<GameStateSnapshot>("GameStateValidation")
    private let actionService = P2PEventService<CardPlaceAction>("GameAction")

    @Published var validationErrors: [String] = []
    @Published var isGameStateValid: Bool = true

    private var receivedSnapshots: [Peer.Identifier: GameStateSnapshot] = [:]
    private var pendingActions: [GameAction] = []

    private let maxPlayers: Int
    private let connectedPlayers: [Peer.Identifier]

    init(maxPlayers: Int) {
        self.maxPlayers = maxPlayers
        connectedPlayers = ([P2PNetwork.myPeer] + P2PNetwork.connectedPeers)
            .prefix(maxPlayers)
            .map(\.id)

        setupValidationService()
        setupActionService()
    }

    // MARK: - 게임 상태 검증

    func validateGameState(snapshot: GameStateSnapshot) {
        // 1. 내 상태와 다른 플레이어들의 상태 비교 요청
        validationService.send(payload: snapshot, reliable: true)

        // 2. 일정 시간 후 검증 결과 확인
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.performValidationCheck(mySnapshot: snapshot)
        }
    }

    private func performValidationCheck(mySnapshot: GameStateSnapshot) {
        let allSnapshots = Array(receivedSnapshots.values) + [mySnapshot]

        // 연결된 모든 플레이어로부터 응답을 받았는지 확인
        guard allSnapshots.count >= connectedPlayers.count else {
            addValidationError("일부 플레이어로부터 게임 상태를 받지 못했습니다.")
            return
        }

        // 턴 번호 일치 확인
        let turnNumbers = Set(allSnapshots.map(\.turnNumber))
        if turnNumbers.count > 1 {
            addValidationError("플레이어들의 턴 번호가 일치하지 않습니다: \(turnNumbers)")
        }

        // 현재 플레이어 일치 확인
        let currentPlayers = Set(allSnapshots.map(\.currentPlayerID))
        if currentPlayers.count > 1 {
            addValidationError("현재 플레이어 정보가 일치하지 않습니다: \(currentPlayers)")
        }

        // 보드 상태 일치 확인
        validateBoardState(snapshots: allSnapshots)

        // 플레이어 손패 수 검증
        validatePlayerHands(snapshots: allSnapshots)

        // 검증 완료
        isGameStateValid = validationErrors.isEmpty
        if !isGameStateValid {
            handleValidationFailure()
        }
    }

    private func validateBoardState(snapshots: [GameStateSnapshot]) {
        let referenceBoardState = snapshots.first?.boardState ?? [:]

        for snapshot in snapshots.dropFirst() {
            let differences = findBoardDifferences(
                reference: referenceBoardState,
                compare: snapshot.boardState
            )

            if !differences.isEmpty {
                addValidationError("보드 상태 불일치 발견: \(differences)")
            }
        }
    }

    private func validatePlayerHands(snapshots: [GameStateSnapshot]) {
        // 각 플레이어별 손패 수가 일치하는지 확인
        var playerHandCounts: [Peer.Identifier: Set<Int>] = [:]

        for snapshot in snapshots {
            for (playerID, handCount) in snapshot.playerHands {
                if playerHandCounts[playerID] == nil {
                    playerHandCounts[playerID] = Set([handCount])
                } else {
                    playerHandCounts[playerID]?.insert(handCount)
                }
            }
        }

        for (playerID, handCounts) in playerHandCounts {
            if handCounts.count > 1 {
                addValidationError("플레이어 \(playerID)의 손패 수가 일치하지 않습니다: \(handCounts)")
            }
        }
    }

    // MARK: - 액션 검증 및 동기화

    func validateAndExecuteAction<T: GameAction>(_ action: T, execute: @escaping (T) -> Bool) {
        // 1. 액션을 다른 플레이어들에게 전송
        if let cardAction = action as? CardPlaceAction {
            actionService.send(payload: cardAction, reliable: true)
        }

        // 2. 로컬에서 액션 실행
        let success = execute(action)

        if success {
            // 3. 액션 실행 후 상태 검증 요청
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // BoardViewModel에서 현재 상태 스냅샷 생성하여 검증
                NotificationCenter.default.post(
                    name: .gameStateValidationRequested,
                    object: nil
                )
            }
        }
    }

    // MARK: - Private Methods

    private func setupValidationService() {
        validationService.onReceive { [weak self] (_: EventInfo, snapshot: GameStateSnapshot, _: [String: Any]?, _: MCPeerID) in
            self?.receivedSnapshots[snapshot.senderID] = snapshot
        }
    }

    private func setupActionService() {
        actionService.onReceive { [weak self] (_: EventInfo, action: CardPlaceAction, _: [String: Any]?, sender: MCPeerID) in
            // 받은 액션을 검증하고 로컬에 적용
            self?.handleReceivedAction(action, from: sender)
        }
    }

    private func handleReceivedAction(_ action: CardPlaceAction, from sender: MCPeerID) {
        // 액션 유효성 검사
        guard isActionValid(action, from: sender) else {
            addValidationError("유효하지 않은 액션을 받았습니다: \(action)")
            return
        }

        // BoardViewModel에 액션 적용 요청
        NotificationCenter.default.post(
            name: .remoteActionReceived,
            object: action
        )
    }

    private func isActionValid(_: CardPlaceAction, from _: MCPeerID) -> Bool {
        // TODO: 구체적인 액션 유효성 검사 로직
        true
    }

    private func findBoardDifferences(
        reference: [String: String],
        compare: [String: String]
    ) -> [String] {
        var differences: [String] = []

        let allKeys = Set(reference.keys).union(Set(compare.keys))

        for key in allKeys {
            let refValue = reference[key]
            let compValue = compare[key]

            if refValue != compValue {
                differences.append("\(key): \(refValue ?? "nil") vs \(compValue ?? "nil")")
            }
        }

        return differences
    }

    private func addValidationError(_ message: String) {
        validationErrors.append(message)
        print("🚨 게임 상태 검증 오류: \(message)")
    }

    private func handleValidationFailure() {
        // 검증 실패 시 처리 로직
        // 예: 게임 일시정지, 재동기화 요청 등
        print("🚨 게임 상태 검증 실패. 재동기화가 필요합니다.")

        // 호스트에게 게임 상태 재동기화 요청
        if let host = P2PNetwork.host, !host.isMe {
            requestGameStateSync(from: host)
        }
    }

    private func requestGameStateSync(from host: Peer) {
        // TODO: 호스트로부터 정확한 게임 상태 요청
        print("호스트 \(host.displayName)로부터 게임 상태 재동기화 요청")
    }
}

// MARK: - 4. BoardViewModel 확장

extension BoardViewModel {
    // 턴 번호 추적을 위한 프로퍼티 (기존 BoardViewModel에 추가 필요)
    var turnNumber: Int {
        // 실제 구현 시 @Published var turnNumber: Int = 0 을 BoardViewModel에 추가
        0 // placeholder
    }

    private var stateValidator: GameStateValidator {
        // 싱글톤으로 관리하거나 의존성 주입 (실제 구현 시 프로퍼티로 관리)
        GameStateValidator(maxPlayers: P2PNetwork.maxConnectedPeers + 1)
    }

    // 기존 카드 배치 함수 수정
    func placeSelectedCardWithValidation() {
        // validateSelectedCard를 public으로 변경하거나 여기서 직접 검증
        guard let selectedCard = selectedCard,
              let myIndex = getMeIndex,
              currentPlayer.value == players[myIndex].peer.id
        else {
            showToast("카드를 선택하거나 차례를 확인해주세요")
            return
        }

        let action = CardPlaceAction(
            playerID: P2PNetwork.myPeer.id,
            timestamp: Date().timeIntervalSince1970,
            turnNumber: turnNumber,
            coordinate: Coordinate(x: cursor.0, y: cursor.1),
            cardType: selectedCard.type.rawValue,
            cardRotation: 0 // 필요시 회전 각도 추가
        )

        stateValidator.validateAndExecuteAction(action) { [weak self] action in
            // 실제 카드 배치 로직
            return self?.executePlaceCard(action) ?? false
        }
    }

    private func executePlaceCard(_ action: CardPlaceAction) -> Bool {
        // 기존 placeSelectedCard() 메서드를 직접 호출하고 결과를 반환
        // 이렇게 하면 private 메서드들에 직접 접근하지 않고도 기존 로직을 재사용할 수 있습니다

        let originalCursor = cursor
        let originalSelectedCard = selectedCard

        // 액션에서 받은 좌표와 카드 정보로 설정
        cursor = (action.coordinate.x, action.coordinate.y)

        // 액션에서 받은 카드 타입으로 selectedCard 찾기
        if let myIndex = getMeIndex {
            selectedCard = players[myIndex].cardsInHand.first { card in
                card.type.rawValue == action.cardType
            }
        }

        // 기존 placeSelectedCard 메서드 호출
        let originalToastMessage = toastMessage
        placeSelectedCard()

        // 성공 여부 판단 (토스트 메시지가 에러 메시지가 아니라면 성공)
        let success = toastMessage == nil ||
            !isErrorMessage(toastMessage ?? "")

        // 실패한 경우 원래 상태로 복원
        if !success {
            cursor = originalCursor
            selectedCard = originalSelectedCard
            toastMessage = originalToastMessage
        }

        return success
    }

    private func isErrorMessage(_ message: String) -> Bool {
        let errorKeywords = ["선택해주세요", "차례입니다", "사용할 수 있습니다", "놓을 수 없습니다"]
        return errorKeywords.contains { message.contains($0) }
    }

    // 주기적 상태 검증
    func performPeriodicValidation() {
        let snapshot = GameStateSnapshot.current(from: self)
        stateValidator.validateGameState(snapshot: snapshot)
    }
}

// MARK: - 5. Notification 확장

extension Notification.Name {
    static let gameStateValidationRequested = Notification.Name("gameStateValidationRequested")
    static let remoteActionReceived = Notification.Name("remoteActionReceived")
}
