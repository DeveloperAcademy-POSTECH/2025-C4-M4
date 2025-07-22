

import Foundation

public class Board {
    public var grid: [[BoardCell]] = Array(repeating: Array(repeating: BoardCell(), count: 5), count: 9)

    public var lastGoal: (x: Int, y: Int)?

    public init() {
        grid[0][2] = BoardCell(isCard: true, directions: [true, true, true, true], symbol: "Ⓢ", isConnect: true, contributor: "") // start
        grid[8][0] = BoardCell(isCard: true, directions: [true, true, true, true], symbol: "G0", isConnect: true, contributor: "", isGoal: false, isOpened: false) // top
        grid[8][2] = BoardCell(isCard: true, directions: [true, true, true, true], symbol: "G1", isConnect: true, contributor: "", isGoal: false, isOpened: false) // middle
        grid[8][4] = BoardCell(isCard: true, directions: [true, true, true, true], symbol: "G2", isConnect: true, contributor: "", isGoal: false, isOpened: false) // bottom
    }

    // 보드 현황을 보여준다
    public func display() {
        for y in 0 ..< grid[0].count {
            var line = "y=\(y)  "
            for x in 0 ..< grid.count {
                line += "\(grid[x][y].description) "
            }
            print(line)
        }
        print("")
    }

    public func setGoal(grandom _: Int) {
        let grandom = Int.random(in: 0 ... 2)
        grid[8][grandom * 2].isGoal = true
    }

    // 카드 설치 가능 여부를 확인한다 - 로직 위주
    public func isPlacable(x: Int, y: Int, card: Card) -> Bool {
        guard x >= 0, x < 9, y >= 0, y < 5 else { return false } // 카드를 설치할 값의 위치가 좌표 위가 아니라면 false

        var trueConnectedCount = 0
        let directions = [(-1, 0, 3, 1), (1, 0, 1, 3), (0, -1, 0, 2), (0, 1, 2, 0)]

        for (dx, dy, myDir, neighborDir) in directions {
            let nx = x + dx
            let ny = y + dy
            guard nx >= 0, nx < 9, ny >= 0, ny < 5 else { continue } // neighbor 카드의 존재 여부 체크
            let neighbor = grid[nx][ny]
            if neighbor.isCard {
                if card.directions[myDir], neighbor.directions[neighborDir] {
                    trueConnectedCount += 1
                    if nx == 8, ny == 2 {
                        trueConnectedCount -= 1
                    }
                } else if card.directions[myDir] != neighbor.directions[neighborDir] {
                    return false // 연결이 안 맞는 방향이 하나라도 있으면 false
                }
            }
        }

        return trueConnectedCount > 0 // true-true인 방향이 있어야 한 개 이상 있으면 true
    }

    // 카드를 설치한다 - 기본적인 isCard나 시작, 도착 지점 여부 확인도 이루어진다
    public func placeCard(x: Int, y: Int, card: Card, player: String) -> (Bool, String) {
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

    // 폭탄 카드를 설치한다
    public func dropBoom(x: Int, y: Int) -> (Bool, String) {
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

    public func goalCheck() -> Bool {
        // print("🔍 goalCheck 시작: start 위치에서 탐색을 시작합니다.")
        var visited = Array(
            repeating: Array(repeating: false, count: grid[0].count),
            count: grid.count
        )
        let dirs = [
            (-1, 0, 3, 1), // 왼쪽
            (1, 0, 1, 3), // 오른쪽
            (0, -1, 0, 2), // 위
            (0, 1, 2, 0), // 아래
        ]
        func dfs(x: Int, y: Int) -> Bool {
            guard x >= 0, x < grid.count, y >= 0, y < grid[0].count else {
                // print("⚠️ (\(x),\(y))는 보드 범위를 벗어났습니다.")
                return false
            }
            guard !visited[x][y] else {
                // print("🔄 (\(x),\(y))는 이미 방문했습니다.")
                return false
            }
            visited[x][y] = true
            // print("🚶‍♂️ 방문: (\(x),\(y)), 심볼: \(grid[x][y].symbol)")

            if x == 8, y == 0 || y == 2 || y == 4, grid[x][y].isOpened == false {
                lastGoal = (x, y)
                // print("🎯 목표에 도달했습니다! (\(x),\(y))")
                return true
            }

            let cell = grid[x][y]
            guard cell.isConnect else {
                // print("❌ (\(x),\(y))는 연결 가능한 카드가 아닙니다.")
                return false
            }

            for (dx, dy, myDir, neighDir) in dirs {
                let nx = x + dx, ny = y + dy
                if nx >= 0, nx < grid.count, ny >= 0, ny < grid[0].count {
                    let neigh = grid[nx][ny]
                    let isGoal = (nx == 8 && (ny == 0 || ny == 2 || ny == 4) && grid[nx][ny].isOpened == false)
                    let canConnect = cell.directions[myDir]
                        && (isGoal || (neigh.isCard && neigh.isConnect))
                        && neigh.directions[neighDir]
                    // print("➡️ 연결 검사: (\(x),\(y)) -> (\(nx),\(ny)) : \(canConnect ? "가능" : "불가능")")
                    if canConnect {
                        if dfs(x: nx, y: ny) {
                            return true
                        }
                    }
                }
            }

            return false
        }
        let result = dfs(x: 0, y: 2)
        // print("✅ goalCheck 종료: 결과 = \(result)")
        return result
    }
}
