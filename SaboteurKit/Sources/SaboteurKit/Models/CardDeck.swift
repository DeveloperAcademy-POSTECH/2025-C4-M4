import Foundation

private let cardDistribution: [CardType: Int] = [
    .pathTR: 3,
    .pathTL: 3,
    .pathTB: 3,
    .pathRL: 3,
    .pathTRB: 2,
    .pathTRL: 2,
    .pathTRBL: 2,

    .blockT: 2,
    .blockL: 2,
    .blockTL: 1,
    .blockTR: 1,
    .blockTB: 1,
    .blockRL: 1,
    .blockTRB: 1,
    .blockTRL: 1,
    .blockTRBL: 1,

    .bomb: 2,
    .map: 2,
]

public struct Deck {
    public var cards: [Card] = []

    public init() {
        refill()
    }

    private mutating func refill() {
        cards.removeAll()
        for (type, count) in cardDistribution {
            for _ in 0 ..< count {
                cards.append(Card(type: type))
            }
        }
        cards.shuffle()
    }

    public mutating func draw() -> Card? {
        if cards.isEmpty {
            refill()
        }
        return cards.popLast()
    }
}
