//
//  main.swift
//  Saboteur-Refactoring
//
//  Created by Nike on 7/14/25.
//

import Foundation

struct Player {
    var name: String
    var nation: String
}

struct Card {
    let directions: [Bool]
    let connect: Bool
    let symbol: String

    var description: String {
        symbol
    }
}

let cardSet: [Card] = [
    Card(directions: [true, false, true, false], connect: true, symbol: "│"), // 상하
    Card(directions: [false, true, false, true], connect: true, symbol: "─"), // 좌우
    Card(directions: [true, true, false, false], connect: true, symbol: "└"), // 상우
    Card(directions: [false, true, true, false], connect: true, symbol: "┌"), // 하우
    Card(directions: [true, true, true, true], connect: true, symbol: "┼"), // 전방향
    Card(directions: [false, false, false, false], connect: false, symbol: "💣"), // 폭탄
    Card(directions: [true, true, true, true], connect: false, symbol: "⦻"), // 전방, 방해
]

struct BoardCell: CustomStringConvertible {
    var isCard: Bool = false
    var directions: [Bool] = [true, true, true, true]
    var symbol: String = "☐"
    var isConnect: Bool = false
    var contributor: String = ""

    var description: String {
        symbol
    }
}

class Board {
    var grid: [[BoardCell]] = Array(repeating: Array(repeating: BoardCell(), count: 5), count: 9)

    init() {
        grid[0][2] = BoardCell(isCard: true, directions: [true, true, true, true], symbol: "Ⓢ", isConnect: true, contributor: "") // start
        grid[8][2] = BoardCell(isCard: false, directions: [true, true, true, true], symbol: "ⓖ", isConnect: true, contributor: "") // goal
    }

    // 보드 현황을 보여준다
    func display() {
        for y in 0 ..< grid[0].count {
            var line = "y=\(y)  "
            for x in 0 ..< grid.count {
                line += "\(grid[x][y].description) "
            }
            print(line)
        }
        print("")
    }

    // 카드 설치 가능 여부를 확인한다 - 로직 위주
    func isPlacable(x: Int, y: Int, card: Card) -> Bool {
        guard x >= 0, x < 9, y >= 0, y < 5 else { return false } // 카드를 설치할 값의 위치가 좌표 위가 아니라면 false

        var trueConnectedCount = 0
        let directions = [(-1, 0, 3, 1), (1, 0, 1, 3), (0, -1, 0, 2), (0, 1, 2, 0)]

        for (dx, dy, myDir, neighborDir) in directions {
            let nx = x + dx
            let ny = y + dy
            guard nx >= 0, nx < 9, ny >= 0, ny < 5 else { continue } // neighbor 카드의 존재 여부 체크
            let neighbor = grid[nx][ny]
            if neighbor.isCard {
                if card.directions[myDir], neighbor.directions[neighborDir], nx != 8 || ny != 2 {
                    trueConnectedCount += 1
                } else if card.directions[myDir] != neighbor.directions[neighborDir] {
                    return false // 연결이 안 맞는 방향이 하나라도 있으면 false
                }
            }
        }

        return trueConnectedCount > 0 // true-true인 방향이 있어야 한 개 이상 있으면 true
    }

    // 카드를 설치한다 - 기본적인 isCard나 시작, 도착 지점 여부 확인도 이루어진다
    func placeCard(x: Int, y: Int, card: Card, player: String) -> Bool {
        if !grid[x][y].isCard {
            if isPlacable(x: x, y: y, card: card) {
                grid[x][y] = BoardCell(isCard: true, directions: card.directions, symbol: card.symbol, isConnect: card.connect, contributor: player)
                return true
            } else {
                print("❌ 해당 위치에 카드를 놓을 수 없습니다.\n")
                return false
            }
        } else {
            print("❌ 이미 카드가 있거나 시작/도착 지점입니다.\n")
            return false
        }
    }

    // 폭탄 카드를 설치한다
    func dropBoom(x: Int, y: Int) -> Bool {
        if (x == 0 && y == 2) || (x == 8 && y == 2) {
            print("❌ 시작/도착 지점은 폭파할 수 없습니다.\n")
            return false
        }
        if grid[x][y].isCard {
            grid[x][y] = BoardCell()
            return true
        } else {
            print("❌ 해당 지점에 카드가 없습니다.\n")
            return false
        }
    }

    func goalCheck() -> Bool {
        true
    }
}

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

                if board.grid[7][2].isCard || board.grid[8][1].isCard || board.grid[8][3].isCard {
                    print("goalCheck를 진행합니다.")
                    if board.goalCheck() {
                        print("🎉 \(currentPlayer.name)가 길을 완성했습니다!")
                        exit(0)
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
