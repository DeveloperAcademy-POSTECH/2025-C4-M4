//
//  PlayerManager.swift
//  Saboteur
//
//  Created by Baba on 7/31/25.
//

import P2PKit
import SaboteurKit
import SwiftUI

extension BoardViewModel {
    // MARK: - 플레이어 정보 접근

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

    var sortedPeers: [Peer] {
        let allPeers = [P2PNetwork.myPeer] + P2PNetwork.connectedPeers
        // 고유 ID 기준으로 정렬
        return allPeers.sorted { $0.id < $1.id }
    }

    var defautPeer: Peer {
        sortedPeers.first ?? P2PNetwork.myPeer
    }

    // MARK: - 플레이어 초기화

    /// 연결된 Peer를 기반으로 플레이어 목록 구성
    func setupPlayers() {
        players = sortedPeers.map { PeerPlayer(peer: $0, nation: "Korean") }
        currentPlayer.value = defautPeer.id
        winner.value = ""
    }

    /// 각 플레이어에게 초기 손패 지급
    func dealInitialHands() {
        for index in players.indices {
            for _ in 0 ..< players[index].maxHandSize {
                players[index].drawCard(from: &currentDeck)
            }
        }
    }
}
