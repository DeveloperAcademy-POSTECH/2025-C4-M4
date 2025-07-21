

import Foundation

public enum PathCardType: CaseIterable, Sendable {
    case t, tb, tr, tl, rl, trb, trl, trbl
    case lBlock, tbBlock, trBlock, tlBlock, rlBlock, trbBlock, trlBlock, trblBlock
    case bomb
}

public struct Card: Sendable {
//    public let type: PathCardType
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
    // 연결 가능한 길 카드
    Card(directions: [true, true, true, false], connect: true, symbol: "┴"),      // t
    Card(directions: [true, true, false, true], connect: true, symbol: "│"),      // tb
    Card(directions: [true, false, true, true], connect: true, symbol: "└"),      // tr
    Card(directions: [true, true, true, false], connect: true, symbol: "┘"),      // tl
    Card(directions: [false, true, false, true], connect: true, symbol: "─"),     // rl
    Card(directions: [true, false, true, true], connect: true, symbol: "├"),      // trb
    Card(directions: [true, true, true, false], connect: true, symbol: "┤"),      // trl
    Card(directions: [true, true, true, true], connect: true, symbol: "┼"),       // trbl

    // 방해 카드
    Card(directions: [false, false, false, false], connect: false, symbol: "⨯"),  // lBlock
    Card(directions: [true, true, false, true], connect: false, symbol: "╵"),     // tbBlock
    Card(directions: [true, false, true, false], connect: false, symbol: "╰"),    // trBlock
    Card(directions: [true, true, false, false], connect: false, symbol: "╯"),    // tlBlock
    Card(directions: [false, true, false, true], connect: false, symbol: "╴"),    // rlBlock
    Card(directions: [true, false, true, true], connect: false, symbol: "┡"),     // trbBlock
    Card(directions: [true, true, true, false], connect: false, symbol: "┩"),     // trlBlock
    Card(directions: [true, true, true, true], connect: false, symbol: "╳"),      // trblBlock

    // 폭탄 카드
    Card(directions: [false, false, false, false], connect: false, symbol: "💣"), // bomb
]
