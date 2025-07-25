import Foundation
import P2PKit
import SaboteurKit

public struct PeerPlayer: Identifiable {
    // MARK: - Identity

    public let id = UUID()
    public let peer: Peer
    public let nation: String

    // MARK: - Hand Management

    private(set) var hand: [Card] = []
    public let maxHandSize = 5

    // 외부에서 손패를 읽기 전용으로 접근 가능
    public var cardsInHand: [Card] { hand }

    // MARK: - Actions

    /// 덱에서 카드를 1장 뽑아 손패에 추가합니다.
    public mutating func drawCard(from deck: inout Deck) {
        guard hand.count < maxHandSize else { return }
        if let card = deck.draw() {
            hand.append(card)
        }
    }

    /// 인덱스로 카드를 제거합니다.
    public mutating func removeCard(at index: Int) -> Card? {
        guard hand.indices.contains(index) else { return nil }
        return hand.remove(at: index)
    }

    /// 지정한 카드를 찾아 제거합니다.
    public mutating func discardCard(_ card: Card) -> Bool {
        if let index = hand.firstIndex(of: card) {
            hand.remove(at: index)
            return true
        }
        return false
    }

    /// 손패를 출력합니다. (디버깅용)
    public func display() {
        let symbols = hand.map(\.symbol)
        print("🃏 내 카드: \(symbols.joined(separator: " "))")
    }
}
