import Foundation

class Board {
    var grid: [[BoardCell]] = Array(repeating: Array(repeating: BoardCell(), count: 5), count: 9)

    init() {
        grid[0][2] = BoardCell(isCard: true, directions: [true, true, true, true], symbol: "Ⓢ", isConnect: true, contributor: "")
        grid[8][2] = BoardCell(isCard: false, directions: [true, true, true, true], symbol: "ⓖ", isConnect: true, contributor: "")
    }

    func isPlacable(x: Int, y: Int, card: Card) -> Bool {
        guard x >= 0, x < 9, y >= 0, y < 5 else { return false }

        var trueConnectedCount = 0
        let directions = [(-1, 0, 3, 1), (1, 0, 1, 3), (0, -1, 0, 2), (0, 1, 2, 0)]

        for (dx, dy, myDir, neighborDir) in directions {
            let nx = x + dx
            let ny = y + dy
            guard nx >= 0, nx < 9, ny >= 0, ny < 5 else { continue }
            let neighbor = grid[nx][ny]
            if neighbor.isCard {
                if card.directions[myDir], neighbor.directions[neighborDir], nx != 8 || ny != 2 {
                    trueConnectedCount += 1
                } else if card.directions[myDir] != neighbor.directions[neighborDir] {
                    return false
                }
            }
        }

        return trueConnectedCount > 0
    }

    func placeCard(x: Int, y: Int, card: Card, player: String) -> (Bool, String) {
        if !grid[x][y].isCard {
            if isPlacable(x: x, y: y, card: card) {
                grid[x][y] = BoardCell(isCard: true, directions: card.directions, symbol: card.symbol, isConnect: card.connect, contributor: player)
                return (true, "🪏 \(player)가 \(card.symbol)를 (\(x),\(y))에 놓았습니다.")
            } else {
                return (false, "❌ 해당 위치에 카드를 놓을 수 없습니다.")
            }
        } else {
            return (false, "❌ 이미 카드가 있거나 시작/도착 지점입니다.")
        }
    }

    func dropBoom(x: Int, y: Int) -> (Bool, String) {
        if (x == 0 && y == 2) || (x == 8 && y == 2) {
            return (false, "❌ 시작/도착 지점은 폭파할 수 없습니다.")
        }
        if grid[x][y].isCard {
            grid[x][y] = BoardCell()
            return (true, "💣 길 카드가 제거되었습니다!")
        } else {
            return (false, "❌ 해당 지점에 카드가 없습니다.")
        }
    }

    func goalCheck() -> Bool {
        true
    }
}
