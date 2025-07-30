import SaboteurKit
import SwiftUI

struct BoardGridView: View {
    let board: [[BoardCell]]
    let placedCards: [Coordinate: BoardCell]
    var cursor: (Int, Int)? = (1, 2)
    let onTapCell: (Int, Int) -> Void
    let latestPlacedCoord: Coordinate? // 가장 최근에 놓인 카드 위치
    let temporarilyRevealedCell: (x: Int, y: Int)?

    // MARK: - Grid Layout

    private let columnCount: Int = 9
    private let rowCount: Int = 5
    private let cellSize: CGFloat = 60
    private let cellSpacing: CGFloat = 4

    private var columns: [GridItem] {
        Array(repeating: GridItem(.fixed(cellSize), spacing: cellSpacing), count: columnCount)
    }

    private var gridIndices: [Int] {
        Array(0 ..< (columnCount * rowCount))
    }

    init(
        board: [[BoardCell]],
        placedCards: [Coordinate: BoardCell],
        cursor: (Int, Int)? = (1, 2),
        onTapCell: @escaping (Int, Int) -> Void,
        latestPlacedCoord: Coordinate?,
        temporarilyRevealedCell: (x: Int, y: Int)?
    ) {
        self.board = board
        self.placedCards = placedCards
        self.cursor = cursor
        self.onTapCell = onTapCell
        self.latestPlacedCoord = latestPlacedCoord
        self.temporarilyRevealedCell = temporarilyRevealedCell
    }

    // MARK: - Body

    var body: some View {
        LazyVGrid(columns: columns, spacing: cellSpacing) {
            ForEach(gridIndices, id: \.self) { index in
                let (x, y) = coordinates(from: index)
                GridCellView(
                    x: x,
                    y: y,
                    cell: cell(at: x, y),
                    isCursor: isCursor(at: x, y),
                    isLatestPlaced: latestPlacedCoord == Coordinate(x: x, y: y),
                    showRevealedGoalImage: temporarilyRevealedCell?.x == x && temporarilyRevealedCell?.y == y,
                    onTap: { onTapCell(x, y) }
                )
            }
        }
    }

    // MARK: - Helpers

    private func coordinates(from index: Int) -> (Int, Int) {
        (index % columnCount, index / columnCount)
    }

    private func cell(at x: Int, _ y: Int) -> BoardCell {
        placedCards[Coordinate(x: x, y: y)] ?? board[x][y]
    }

    private func isCursor(at x: Int, _ y: Int) -> Bool {
        (cursor ?? (-1, -1)) == (x, y)
    }
}

// #Preview {
//     let placed = ["3,2": BoardCell(type: CardType.blockL)]
//     let latestCoord = Coordinate(x: 3, y: 2)

//     BoardGridView(
//         board: Board().grid,
//         placedCards: placed,
//         cursor: (3, 3),
//         onTapCell: { x, y in print("Tapped: (\(x), \(y))") },
//         latestPlacedCoord: latestCoord
//     )
//     .padding()
// }
