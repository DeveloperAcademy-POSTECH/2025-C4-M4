import SaboteurKit
import SwiftUI

struct GridCellView: View {
    let x: Int
    let y: Int
    let cell: BoardCell
    let isCursor: Bool
    let isLatestPlaced: Bool // 가장 최근에 놓인 카드에 두께를 주기 위함
    let onTap: () -> Void

    // MARK: - Semantic Helpers

    private var hasCard: Bool {
        cell.type != nil
    }

    private var isRoadCard: Bool {
        cell.type?.imageName.contains("Road") == true
    }

    private var shadowColor: Color {
        // !hasCard || !isRoadCard ? Color.clear : Color.Emerald.emerald1
        guard hasCard, isRoadCard else { return .clear }
        return isLatestPlaced ? Color.Emerald.emerald2 : Color.Emerald.emerald1
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            backgroundLayer
            cursorOverlay
            imageLayer
        }
        .frame(width: 60, height: 50)
        .shadow(color: shadowColor, radius: 0, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .zIndex(hasCard ? 1 : 0)
        .overlay(
            Group {
                if isLatestPlaced {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.Emerald.emerald2, lineWidth: 1)
                }
            }
        )
        .padding(2)
    }

    // MARK: - View Components

    var backgroundLayer: some View {
        Group {
            if !hasCard {
                Rectangle()
                    .foregroundColor(.clear)
                    .background(Color.Emerald.emerald4.opacity(0.4))
                    .cornerRadius(4)
            }
        }
    }

    var imageLayer: some View {
        Group {
            if let imageName = cell.type?.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }

    var cursorOverlay: some View {
        Group {
            if isCursor {
                Rectangle()
                    .stroke(Color.yellow, lineWidth: 3)
                    .cornerRadius(4)
            }
        }
    }
}

#Preview {
    GridCellView(
        x: 0, y: 0,
        cell: BoardCell(type: CardType.blockTB),
        isCursor: false,
        isLatestPlaced: true,
        onTap: { print("Tapped") }
    )
}
