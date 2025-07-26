import Foundation

private let cardDistribution: [CardType: Int] = [
    .pathTR: 2,
    .pathTL: 2,
    .pathTB: 2,
    .pathRL: 3,
    .pathTRB: 2,
    .pathTRL: 2,
    .pathTRBL: 2,
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
