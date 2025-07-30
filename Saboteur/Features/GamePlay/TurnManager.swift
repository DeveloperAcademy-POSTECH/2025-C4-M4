//
//  TurnManager.swift
//  Saboteur
//
//  Created by Baba on 7/31/25.
//

import SwiftUI
import P2PKit
import SaboteurKit

extension BoardViewModel {
    // MARK: - 턴 관리
    
    /// 다음 플레이어로 턴 넘기기
    func nextTurn() {
        let players = self.players
        guard let currentIndex = players.firstIndex(where: { $0.peer.id == currentPlayer.value }) else { return }
        let nextPlayerID = players[(currentIndex + 1) % players.count].peer.id
        print("⏭️ \(currentPlayer.value) → \(nextPlayerID) 로 턴 넘김")
        currentPlayer.value = nextPlayerID
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
    
    // MARK: - 목표 완성 확인
    
    /// 길 완성 여부 확인
    func checkGoalCompletion() {
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

            // 3) 토스트 알림
            sendToast("🎉 \(myName)가 길을 완성했습니다!", target: .global)

            // 4) n초 후 승패 동기화
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.winner.value = P2PNetwork.myPeer.id
            }
        }
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
    
    // MARK: - 게임 리셋
    
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
}
