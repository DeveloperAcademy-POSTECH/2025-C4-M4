import SaboteurKit
import SwiftUI

struct CardSelectionView: View {
    let cards: [Card]
    @Binding var selectedCard: Card?
    let onSelect: (Card) -> Void

    var body: some View {
        HStack {
            ForEach(cards, id: \.id) { card in
                Button(action: {
                    selectedCard = card
                    onSelect(card)
                }) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 60, height: 50)
                        .background(
                            ZStack {
                                Image(card.type.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 50)
                                    .clipped()

                                if isSelected(card) {
                                    Color.blue.opacity(0.3)
                                        .cornerRadius(4)
                                }
                            }
                        )
                        .cornerRadius(4)
                        .shadow(color: Color.blue, radius: 0, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .inset(by: 0.5)
                                .stroke(
                                    isSelected(card) ? Color.blue : Color.gray,
                                    lineWidth: 2
                                )
                        )
                }
            }
        }
        .foregroundStyle(Color.Emerald.emerald3)
        .padding(.horizontal, 36)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .inset(by: 1)
                .fill(Color.Emerald.emerald3.shadow(.inner(color: Color.Emerald.emerald1, radius: 0, x: 0, y: -4))) // 배경색, 드롭쉐도우
                .stroke(Color.Emerald.emerald1, lineWidth: 2) // 이너 스트라이크
        }
    }

    private func isSelected(_ card: Card) -> Bool {
        selectedCard?.id == card.id
    }
}
