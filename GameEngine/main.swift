
import Foundation

struct BoardCell: CustomStringConvertible {
    var isCard: Bool = false
    var directions: [Bool] = [true, true, true, true]
    var symbol: String = "☐"
    var isConnect: Bool = false

    var description: String {
        symbol
    }
}

class Board {
    var grid: [[BoardCell]] = Array(repeating: Array(repeating: BoardCell(), count: 9), count: 5)

    init() {
        grid[2][0] = BoardCell(isCard: true, directions: [true, true, true, true], symbol: "Ⓢ", isConnect: true) // start
        grid[2][8] = BoardCell(isCard: false, directions: [true, true, true, true], symbol: "ⓖ", isConnect: true) // goal
    }

    func isPlacable(x: Int, y: Int, card: Card) -> Bool {
        guard x >= 0, x < 9, y >= 0, y < 5 else { return false }

        var adjacentConnected = 0
        let directions = [(-1, 0, 3, 1), (1, 0, 1, 3), (0, -1, 0, 2), (0, 1, 2, 0)] // (dx, dy, myDir, neighborDir)

        for (dx, dy, myDir, neighborDir) in directions {
            let nx = x + dx
            let ny = y + dy
            guard nx >= 0, nx < 9, ny >= 0, ny < 5 else { continue }
            let neighbor = grid[ny][nx]
            if neighbor.isCard {
                if card.directions[myDir], neighbor.directions[neighborDir], nx != 8 || ny != 2 {
                    adjacentConnected += 1
                } else if card.directions[myDir] != neighbor.directions[neighborDir] {
                    return false // 연결이 안 맞는 방향이 하나라도 있으면 false
                }
            }
        }

        return adjacentConnected > 0
    }

    func display() {
        for y in 0 ..< grid.count {
            var line = "y=\(y)  "
            for x in 0 ..< grid[0].count {
                line += "\(grid[y][x].description) "
            }
            print(line)
        }
        print("")
    }

    func placeCard(x: Int, y: Int, card: Card) {
        // 나중에 placable 조건 추가 가능
        guard x >= 0, x < 9, y >= 0, y < 5 else {
            print("❌ 범위를 벗어났습니다.\n")
            return
        }

        if !grid[y][x].isCard {
            if isPlacable(x: x, y: y, card: card) {
                grid[y][x] = BoardCell(isCard: true, directions: card.directions, symbol: card.symbol, isConnect: card.connect)
                print("✅ \(x), \(y)에 카드가 놓였습니다.\n")
            } else {
                print("❌ 해당 위치에 카드를 놓을 수 없습니다.\n")
            }
        } else {
            print("❌ 이미 카드가 있거나 시작/도착 지점입니다.\n")
        }
    }
}

let availableCards: [Card] = [
    Card(directions: [true, false, true, false], connect: true, symbol: "│"), // 상하
    Card(directions: [false, true, false, true], connect: true, symbol: "─"), // 좌우
    Card(directions: [true, true, false, false], connect: true, symbol: "└"), // 상우
    Card(directions: [false, true, true, false], connect: true, symbol: "┌"), // 하우
    Card(directions: [true, true, true, true], connect: true, symbol: "┼"), // 전방향
    Card(directions: [false, false, false, false], connect: false, symbol: "💣"), // 폭탄
]

func useBoom() {
    print("💥 폭탄을 사용할 좌표를 입력하세요 (예: 3 2): ", terminator: "")
    guard let positionInput = readLine(),
          let x = Int(positionInput.split(separator: " ")[0]),
          let y = Int(positionInput.split(separator: " ")[1])
    else {
        print("❌ 잘못된 입력입니다.\n")
        return
    }

    if (x == 0 && y == 2) || (x == 8 && y == 2) {
        print("❌ 시작/도착 지점은 폭파할 수 없습니다.\n")
        return
    }

    if board.grid[y][x].isCard {
        board.grid[y][x] = BoardCell() // 빈 칸으로 초기화
        print("💣 (\(x), \(y)) 폭탄으로 제거되었습니다!\n")
    } else {
        print("❗️해당 위치에는 카드가 없습니다.\n")
    }
}

func selectCard() -> Card? {
    print("\n사용할 카드 번호를 선택하세요:")
    for (index, card) in availableCards.enumerated() {
        print("[\(index)] \(card.description)")
    }
    print("카드 번호 입력: ", terminator: "")

    guard let input = readLine() else {
        print("❌ 입력이 없습니다.")
        return nil
    }

    if input == "5" {
        useBoom()
        return nil
    }

    guard let idx = Int(input), idx >= 0, idx < availableCards.count - 1 else {
        print("❌ 잘못된 입력입니다.")
        return nil
    }

    return availableCards[idx]
}

struct Card {
    let directions: [Bool] // [상, 우, 하, 좌]
    let connect: Bool
    let symbol: String // 보드에 표시될 카드 모양

    var description: String {
        "\(symbol)"
    }
}

let board = Board()

while true {
    board.display()

    print("게임을 끝내려면 'end'를 입력하세요. 계속하려면 Enter: ", terminator: "")
    if let quitInput = readLine(), quitInput.lowercased() == "end" {
        print("👋 게임을 종료합니다.")
        break
    }

    guard let selectedCard = selectCard() else { continue }
    print("카드를 놓을 위치 (x y)를 입력하세요 (예: 3 2): ", terminator: "")
    guard let positionInput = readLine(),
          let x = Int(positionInput.split(separator: " ")[0]),
          let y = Int(positionInput.split(separator: " ")[1])
    else {
        print("❌ 잘못된 입력입니다.\n")
        continue
    }

    board.placeCard(x: x, y: y, card: selectedCard)
}
