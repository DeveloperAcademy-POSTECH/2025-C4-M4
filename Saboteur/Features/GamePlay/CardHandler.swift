//
//  CardHandler.swift
//  Saboteur
//
//  Created by Baba on 7/31/25.
//

import SwiftUI
import P2PKit
import SaboteurKit

extension BoardViewModel {
    // MARK: - 카드 유효성 검사
    
    /// 카드 유효성 검사
    func validateSelectedCard() -> (Card, Int)? {
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
    
    // MARK: - 카드 배치
    
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
    
    // MARK: - 카드 타입별 처리
    
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
        if success == true {
            sendToast("\(myName)님이 먹구름 카드로 길을 없앴습니다", target: .other)
        }
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
    
    // MARK: - 카드 조작
    
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
        guard !discardCooldown else {
            print("🔒 discardCard: 이미 진행 중이므로 무시됩니다.")
            return
        }

        discardCooldown = true

        guard let (card, myIndex) = validateSelectedCard() else {
            discardCooldown = false
            return
        }

        if players[myIndex].discardCard(card) {
            players[myIndex].drawCard(from: &currentDeck)
            selectedCard = nil
            sendToast("\(myName)님이 카드를 버리고 새로 뽑았습니다", target: .other)
            showToast("카드를 버리고 새로 뽑았습니다")
            // 내가 현재 턴을 가진 경우에만 턴 넘기기
            if currentPlayer.value == P2PNetwork.myPeer.id {
                nextTurn()
            }
        } else {
            showToast("카드를 선택해주세요")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.discardCooldown = false
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
    
    // MARK: - 보드 업데이트
    
    /// 보드 셀 업데이트
    func updateCell(at pos: (Int, Int), with card: Card, isCard _: Bool) {
        let cell = BoardCell(type: card.type, contributor: currentPlayer.value)

        placedCards.value[Coordinate(x: pos.0, y: pos.1)] = cell
        print("\(placedCards.value)")
        board.grid[pos.0][pos.1] = cell

        latestPlacedCoord.value = Coordinate(x: pos.0, y: pos.1)
    }

    /// 카드 폐기 후 새 카드 뽑기
    func removeCardAndDrawNew(for index: Int, card: Card) {
        players[index].discardCard(card)
        players[index].drawCard(from: &currentDeck)
    }
    
    /// 공개된 goal 셀(isOpened = true) 상태를 P2P로 전파
    func syncGoalOpenStates() {
        for (gx, gy) in Board.goalPositions {
            let cell = board.grid[gx][gy]
            if cell.isOpened == true {
                placedCards.value[Coordinate(x: gx, y: gy)] = cell
            }
        }
    }
    
    /// P2P 동기화된 카드 배치를 로컬 보드에 반영
    func syncBoardWithPlacedCards() {
        for (coord, cell) in placedCards.value {
            board.grid[coord.x][coord.y] = cell
        }
    }
}
