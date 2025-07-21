
import Foundation
import SaboteurKit

// 사용할 카드를 선택한다
func selectCard() -> Card? {
    print("🎲 카드 덱")
    for (index, card) in cardSet.enumerated() {
        print("[\(index)] \(card.description)")
    }
    print("🎲 사용할 카드 번호를 입력하세요. > ", terminator: "")

    guard let input = readLine() else {
        print("❌ 입력이 없습니다.")
        return nil
    }

    guard let idx = Int(input), idx >= 0, idx < cardSet.count else {
        print("❌ 잘못된 입력입니다.")
        return nil
    }

    return cardSet[idx]
}

// 게임이 진행

// #1. 플레이어의 숫자를 입력받는다
var numberOfPlayers: Int = 2
while true {
    print("🎲 플레이어 수를 입력하세요 (2~4) > ", terminator: "")
    if let input = readLine(), let num = Int(input), (2 ... 4).contains(num) {
        numberOfPlayers = num
        break
    } else {
        print("❌ 잘못된 입력입니다. 2~4 사이로 입력해주세요.")
    }
}

let players = (1 ... numberOfPlayers).map { Player(name: "P\($0)", nation: "Korean") }
var currentPlayerIndex = 0
var currentPlayer: Player { players[currentPlayerIndex] }

let board = Board()

var goal = board.setGoal

while true {
    print("게임을 끝내려면 'stop'를 입력하세요. 계속하려면 Enter > ", terminator: "")
    if readLine() == "stop" { break }

    // #2. 보드 현황을 보여준다
    board.display()

    print("🦹 \(currentPlayer.name)의 턴입니다.")

    while true {
        // #3. 카드를 선택한다
        let card = selectCard()

        guard let selectedCard = card else { continue }

        // #4. 카드를 설치할 위치를 선택한다
        print("🎲 카드를 놓을 위치 (x y)를 입력하세요 (예: 3 2) > ", terminator: "")
        guard let input = readLine(),
              let x = Int(input.split(separator: " ")[0]),
              let y = Int(input.split(separator: " ")[1]),
              x >= 0, x < 9, y >= 0, y < 5
        else {
            print("❌ 잘못된 입력입니다.")
            continue
        }

        // #5. 카드 설치를 수행한다
        if selectedCard.symbol == "💣" {
            if board.dropBoom(x: x, y: y) {
                print("💣 \(currentPlayer.name)가 (\(x),\(y)) 길 카드를 제거했습니다!\n")
                currentPlayerIndex = (currentPlayerIndex + 1) % players.count
                break
            } else { continue }
        } else {
            if board.placeCard(x: x, y: y, card: selectedCard, player: currentPlayer.name) {
                print("🪏 \(currentPlayer.name)가 \(selectedCard.symbol)를 (\(x),\(y))에 놓았습니다.\n")

                if board.grid[7][2].isCard
                    || board.grid[8][1].isCard
                    || board.grid[8][3].isCard
                    || board.grid[7][0].isCard
                    || board.grid[7][4].isCard
                {
                    let pathComplete = board.goalCheck()
                    if pathComplete {
                        if let goal = board.lastGoal {
                            // 보드셀의 isGoal이 true일 때
                            if board.grid[goal.x][goal.y].isGoal == true {
                                print("🎉 \(currentPlayer.name)가 길을 완성했습니다!")
                                exit(0)
                            } else {
                                board.grid[goal.x][goal.y].isOpened = true
                                board.grid[goal.x][goal.y].symbol = "┼"
                                print("🎲 G\(goal.y / 2)에는 보석이 없습니다.\n")
                            }
                        }
                    }
                }
                currentPlayerIndex = (currentPlayerIndex + 1) % players.count
                break
            }
        }
    }
}

/*
 1. 보드를 보여준다
 2. 카드를 선택한다
 3. 카드 위치를 선택한다
 4. 카드 설치를 수행한다
 */
