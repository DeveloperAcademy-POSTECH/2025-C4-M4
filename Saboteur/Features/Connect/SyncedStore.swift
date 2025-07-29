//
//  SyncedStore.swift
//  Saboteur
//
//  Created by 이주현 on 7/28/25.
//

import Foundation
import P2PKit

final class SyncedStore {
    static let shared = SyncedStore()

    let winner = P2PSyncedObservable<Peer.Identifier>(name: "GameWinner", initial: "")
    let exitToastMessage = P2PSyncedObservable<String>(name: "ExitToastMessage", initial: "")
}
