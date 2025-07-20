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

    public mutating func draw() -> Card? {
        if cards.isEmpty {
            return nil
        }
        return cards.removeLast()
    }
}
