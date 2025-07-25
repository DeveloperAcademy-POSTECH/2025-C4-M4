import Foundation

public enum PathCardType: CaseIterable, Sendable {
    case t, tb, tr, tl, rl, trb, trl, trbl
    case lBlock, tbBlock, trBlock, tlBlock, rlBlock, trbBlock, trlBlock, trblBlock
    case bomb
}

public struct Card: Sendable, Equatable {
//    public let type: PathCardType
    public var directions: [Bool]
    public let connect: Bool
    public let symbol: String
    public let imageName: String

    public var description: String {
        symbol
    }

    public init(directions: [Bool], connect: Bool, symbol: String, imageName: String) {
        self.directions = directions
        self.connect = connect
        self.symbol = symbol
        self.imageName = imageName
    }

    public mutating func turnCard() {
        let d = directions
        directions = [d[2], d[3], d[0], d[1]]
    }
}

public let cardSet: [Card] = [
    // 연결 가능한 길 카드
    Card(directions: [true, false, false, true], connect: true, symbol: "┘", imageName: "Card/Road/tl"), // tl
    Card(directions: [true, true, false, false], connect: true, symbol: "└", imageName: "Card/Road/tr"), // tr
    Card(directions: [true, false, true, true], connect: true, symbol: "│", imageName: "Card/Road/tb"), // tb
    Card(directions: [false, true, false, true], connect: true, symbol: "─", imageName: "Card/Road/rl"), // rl
    Card(directions: [true, true, true, false], connect: true, symbol: "├", imageName: "Card/Road/trb"), // trb
    Card(directions: [true, true, false, true], connect: true, symbol: "ㅗ", imageName: "Card/Road/trl"), // trl
    Card(directions: [true, true, true, true], connect: true, symbol: "┼", imageName: "Card/Road/trbl"), // trbl

    // 방해 카드
    Card(directions: [true, false, false, false], connect: false, symbol: "▴", imageName: "Card/Road/t_block"), // t_block
    Card(directions: [false, false, false, true], connect: false, symbol: "◀︎", imageName: "Card/Road/l_block"), // l_block
    Card(directions: [true, false, false, true], connect: false, symbol: "▴◀︎", imageName: "Card/Road/tl_block"), // tl_block
    Card(directions: [true, true, false, false], connect: false, symbol: "╰", imageName: "Card/Road/tr_block"), // tr_block
    Card(directions: [true, false, true, true], connect: false, symbol: "▴▾", imageName: "Card/Road/tb_block"), // tb_block
    Card(directions: [false, true, false, true], connect: false, symbol: "◀︎‣", imageName: "Card/Road/rl_block"), // rl_block
    Card(directions: [true, true, true, false], connect: false, symbol: "▴‣▾", imageName: "Card/Road/trb_block"), // trb_block
    Card(directions: [true, true, false, true], connect: false, symbol: "▴‣◀︎", imageName: "Card/Road/trl_block"), // trl_block
    Card(directions: [true, true, true, true], connect: false, symbol: "╳", imageName: "Card/Road/trbl_block"), // trbl_block

    // 폭탄 카드
    Card(directions: [false, false, false, false], connect: false, symbol: "💣", imageName: "Card/Road/bomb"), // bomb
]
