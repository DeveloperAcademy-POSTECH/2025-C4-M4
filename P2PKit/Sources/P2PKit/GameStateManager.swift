//
//  GameStateManager.swift
//  P2PKit
//
//  Created by 이주현 on 7/27/25.
//

import Foundation

public enum GameState: String {
    case unstarted
    case startedGame
    case pausedGame

    case endGame
}

public final class GameStateManager: ObservableObject {
    public static let shared = GameStateManager()

    @Published public var current: GameState = .unstarted
}
