import Foundation

public struct Player {
    public var name: String
    public var nation: String
    public private(set) var hand: [Card] = []
    public let maxCount: Int
    
    public init(name: String, nation: String, maxCount: Int = 5) {
        self.name = name
        self.nation = nation
        self.maxCount = maxCount
        // 카드 5장 충전!
    }
    
    public mutating func drawCard(from deck: inout Deck) -> Bool {
        guard hand.count < maxCount, let card = deck.draw() else {
            return false
        }
        hand.append(card)
        return true
    }
    
    public func display() {
        let symbols = hand.map { $0.symbol }
        print("🃏 내 카드: \(symbols.joined(separator: " "))")
    }
}
