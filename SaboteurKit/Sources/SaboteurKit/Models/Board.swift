import Foundation

public class Board {
    public static let goalPositions = [(8, 0), (8, 2), (8, 4)]
    public var grid: [[BoardCell]] = Array(repeating: Array(repeating: BoardCell(), count: 5), count: 9)
    public var lastGoal: (x: Int, y: Int)?

    public init(goalIndex: Int) {
        grid[0][2] = BoardCell(type: .start)

        for (index, pos) in Self.goalPositions.enumerated() {
            grid[pos.0][pos.1] = BoardCell(
                type: index == goalIndex ? .goalTrue : .goalFalse,
                isGoal: index == goalIndex,
                isOpened: false
            )
        }
    }

    // 보드 현황을 보여준다
    public func display() {
        for y in 0 ..< grid[0].count {
            var line = "y=\(y)  "
            for x in 0 ..< grid.count {
                line += "\(grid[x][y].symbol) "
            }
            print(line)
        }
        print("")
    }

    /// 해당 좌표가 목적지 라인인지 확인
    public func isGoalLine(x: Int, y: Int) -> Bool {
        Board.goalPositions.contains(where: { $0.0 == x && $0.1 == y })
    }

    public func mapCheck(x: Int, y: Int) -> (Bool, String) {
        if isGoalLine(x: x, y: y) == false {
            return (false, "해당 지점은 확인할 수 없습니다.")
        }

        if grid[x][y].isGoal == true {
            return (true, "g\(y/2)이 goal이 맞습니다.")
        } else {
            return (true, "g\(y/2)은 goal이 아닙니다.")
        }
    }

    public func revealAllGoals() {
        for (gx, gy) in Board.goalPositions {
            grid[gx][gy].isOpened = true
        }
    }

    public func isValidPosition(x: Int, y: Int) -> Bool {
        (0 ..< grid.count).contains(x) && (0 ..< grid[0].count).contains(y)
    }

    public func checkAndRevealGoal(fromX x: Int, y: Int) -> Bool {
        var revealed = false

        for (gx, gy) in Board.goalPositions {
            let dx = abs(gx - x)
            let dy = abs(gy - y)

            guard dx + dy == 1 else { continue } // 인접한 경우만

            let goalCell = grid[gx][gy]
            guard goalCell.type?.category == .goal, goalCell.isOpened == false else { continue }

            grid[gx][gy].isOpened = true
            print("🎯 Goal 카드가 열렸습니다: (\(gx), \(gy))")
            revealed = true
        }

        return revealed
    }

    // 카드 설치 가능 여부를 확인한다 - 로직 위주
    public func isPlacable(x: Int, y: Int, card: Card) -> Bool {
        guard x >= 0, x < 8, y >= 0, y < 5 else { return false }

        var trueConnectedCount = 0
        let directions = [(-1, 0, 3, 1), (1, 0, 1, 3), (0, -1, 0, 2), (0, 1, 2, 0)]

        for (dx, dy, myDir, neighborDir) in directions {
            let nx = x + dx
            let ny = y + dy
            guard nx >= 0, nx < 9, ny >= 0, ny < 5 else { continue }
            let neighbor = grid[nx][ny]

            if isGoalLine(x: nx, y: ny) ? (neighbor.isOpened == true) : neighbor.isCard {
                if card.type.directions[myDir], neighbor.directions[neighborDir] {
                    trueConnectedCount += 1
                    if isGoalLine(x: nx, y: ny), neighbor.isOpened == false {
                        trueConnectedCount -= 1
                    }
                } else if card.type.directions[myDir] != neighbor.directions[neighborDir] {
                    return false
                }
            }
        }

        return trueConnectedCount > 0
    }

    // 카드를 설치한다 - 기본적인 isCard나 시작, 도착 지점 여부 확인도 이루어진다
    public func placeCard(x: Int, y: Int, card: Card, player: String) -> (Bool, String) {
        if !grid[x][y].isCard {
            if isPlacable(x: x, y: y, card: card) {
                grid[x][y] = BoardCell(type: card.type, contributor: player)
                return (true, "🪏 \(player)가 \(card.type.symbol)를 (\(x),\(y))에 놓았습니다.")
            } else {
                return (false, "❌ 해당 위치에 카드를 놓을 수 없습니다.")
            }
        } else {
            return (false, "❌ 이미 카드가 있거나 시작/도착 지점입니다.")
        }
    }

    // 폭탄 카드를 설치한다
    public func dropBoom(x: Int, y: Int) -> (Bool, String) {
        if (x == 0 && y == 2) || isGoalLine(x: x, y: y) {
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

            if isGoalLine(x: x, y: y), grid[x][y].isOpened == false {
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
                    let isGoal = isGoalLine(x: nx, y: ny) && grid[nx][ny].isOpened == false
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
