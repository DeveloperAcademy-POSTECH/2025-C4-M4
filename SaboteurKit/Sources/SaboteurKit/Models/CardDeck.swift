import Foundation

private let cardDistribution: [CardType: Int] = [
    .pathTL: 3,
    .pathTB: 3,
    .pathRL: 3,
    .pathTRB: 3,
    .pathTRL: 3,
    .pathTR: 5,
    .pathTRBL: 3,
    .blockTL: 1,
    .blockRL: 1,
    .blockR: 1,
    .blockTRB: 1,
    .blockTRL: 1,
    .blockT: 1,
    .blockTRBL: 1,
    .blockTR: 1,
    .blockTB: 1,
    .map: 4,
//    .bomb: 6,
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
