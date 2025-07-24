import Foundation

private let cardDistribution: [Int] = [1, 1, 1, 1, 1, 1, 1]

public struct Deck {
    public var cards: [Card] = []

    public init() {
        for (index, count) in cardDistribution.enumerated() {
            for _ in 0 ..< count {
                cards.append(cardSet[index])
            }
        }
        cards.shuffle()
    }

    private mutating func refill() {
        cards.removeAll()
        for (index, count) in cardDistribution.enumerated() {
            for _ in 0 ..< count {
                cards.append(cardSet[index])
            }
        }
        cards.shuffle()
    }

    public mutating func draw() -> Card? {
        if cards.isEmpty {
            refill()
        }
        return cards.removeLast()
    }
}
