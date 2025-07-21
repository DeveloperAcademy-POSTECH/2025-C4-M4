

import Foundation

public struct Card: Sendable {
    public let directions: [Bool]
    public let connect: Bool
    public let symbol: String

    public var description: String {
        symbol
    }

    public init(directions: [Bool], connect: Bool, symbol: String) {
        self.directions = directions
        self.connect = connect
        self.symbol = symbol
    }
}

public let cardSet: [Card] = [
    Card(directions: [true, false, true, false], connect: true, symbol: "│"), // 상하
    Card(directions: [false, true, false, true], connect: true, symbol: "─"), // 좌우
    Card(directions: [true, true, false, false], connect: true, symbol: "└"), // 상우
    Card(directions: [false, true, true, false], connect: true, symbol: "┌"), // 하우
    Card(directions: [true, true, true, true], connect: true, symbol: "┼"), // 전방향
    Card(directions: [false, false, false, false], connect: false, symbol: "💣"), // 폭탄
    Card(directions: [true, true, true, true], connect: false, symbol: "⦻"), // 전방, 방해
]
