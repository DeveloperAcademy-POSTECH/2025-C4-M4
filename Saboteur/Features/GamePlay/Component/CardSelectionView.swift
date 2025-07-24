import SaboteurKit
import SwiftUI

struct CardSelectionView: View {
    let cards: [Card]
    @Binding var selectedCard: Card?
    let onSelect: (Card) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ForEach(cards, id: \.symbol) { card in
                    Button(action: {
                        selectedCard = card
                        onSelect(card)
                    }) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 60, height: 50)
                            .background(
                                ZStack {
                                    Image(card.imageName)
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
        }
        .padding(.horizontal, 36)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .frame(width: 388, height: 72, alignment: .topLeading)
        .background(Color.Emerald.emerald3)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .inset(by: 1)
                .stroke(Color.Emerald.emerald1, lineWidth: 2)
        )
    }

    private func isSelected(_ card: Card) -> Bool {
        selectedCard?.symbol == card.symbol
    }
}
