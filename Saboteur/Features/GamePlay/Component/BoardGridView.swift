import SaboteurKit
import SwiftUI

struct BoardGridView: View {
    let board: [[BoardCell]]
    let placedCards: [String: BoardCell]
    let cursor: (Int, Int)?
    let onTapCell: (Int, Int) -> Void

    // MARK: - Grid Layout

    private let columnCount: Int = 9
    private let rowCount: Int = 5
    private let cellSize: CGFloat = 60
    private let cellSpacing: CGFloat = 2

    private var columns: [GridItem] {
        Array(repeating: GridItem(.fixed(cellSize), spacing: cellSpacing), count: columnCount)
    }

    private var gridIndices: [Int] {
        Array(0 ..< (columnCount * rowCount))
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
        let key = "\(x),\(y)"
        return placedCards[key] ?? board[x][y]
    }

    private func isCursor(at x: Int, _ y: Int) -> Bool {
        (cursor ?? (-1, -1)) == (x, y)
    }
}
