

import Foundation

public struct BoardCell: Codable, Equatable {
    public var type: CardType? = nil // nil이면 카드 없음
    public var contributor: String = ""
    public var isGoal: Bool? = nil
    public var isOpened: Bool? = nil

    public init(type: CardType? = nil, contributor: String = "", isGoal: Bool? = nil, isOpened: Bool? = nil) {
        self.type = type
        self.contributor = contributor
        self.isGoal = isGoal
        self.isOpened = isOpened
    }

    public var isCard: Bool {
        type != nil
    }

    public var directions: [Bool] {
        type?.directions ?? [false, false, false, false]
    }

    public var isConnect: Bool {
        type?.connect ?? false
    }

    public var symbol: String {
        type?.symbol ?? "□"
    }

    public var imageName: String {
        type?.imageName ?? ""
    }
}
