

import Foundation

public struct Card {
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
