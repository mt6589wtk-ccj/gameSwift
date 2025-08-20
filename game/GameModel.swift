import Foundation
import Combine

enum MoveDirection {
    case up, down, left, right
}

class GameModel: ObservableObject {
    // 4x4 網格
    @Published var grid: [[Int]]
    // 遊戲結束
    @Published var isGameOver: Bool
    // 遊戲勝利
    @Published var hasWon: Bool
    // 得分
    @Published var score: Int
    
    let gridSize: Int = 4
    
    init() {
        self.grid = Array(repeating: Array(repeating: 0, count: gridSize), count: gridSize)
        self.isGameOver = false
        self.hasWon = false
        self.score = 0
        startGame()
    }
    
    // 開始新遊戲
    func startGame() {
        self.isGameOver = false
        self.hasWon = false
        self.score = 0
        grid = Array(repeating: Array(repeating: 0, count: gridSize), count: gridSize)
        addRandomTile()
        addRandomTile()
    }
    
    // 重啟
    func restart() {
        startGame()
    }
    
    // 新增隨機 2 或 4
    func addRandomTile() {
        var emptyTiles: [(Int, Int)] = []
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if grid[row][col] == 0 {
                    emptyTiles.append((row, col))
                }
            }
        }
        guard !emptyTiles.isEmpty else { return }
        let (row, col) = emptyTiles.randomElement()!
        grid[row][col] = [2, 2, 2, 4].randomElement()! // 75% 2, 25% 4
    }
    
    // 主要移動與合併邏輯
    func moveTiles(direction: MoveDirection) {
        if isGameOver || hasWon { return }
        var moved = false
        var addedScore = 0
        
        switch direction {
        case .left:
            for i in 0..<gridSize {
                let (newLine, score) = combineTiles(line: grid[i])
                if grid[i] != newLine {
                    moved = true
                    grid[i] = newLine
                }
                addedScore += score
            }
        case .right:
            for i in 0..<gridSize {
                let reversed = Array(grid[i].reversed())
                let (combined, score) = combineTiles(line: reversed)
                let newLine = Array(combined.reversed())
                if grid[i] != newLine {
                    moved = true
                    grid[i] = newLine
                }
                addedScore += score
            }
        case .up:
            for col in 0..<gridSize {
                var column = (0..<gridSize).map { grid[$0][col] }
                let (newColumn, score) = combineTiles(line: column)
                for row in 0..<gridSize {
                    if grid[row][col] != newColumn[row] {
                        moved = true
                        grid[row][col] = newColumn[row]
                    }
                }
                addedScore += score
            }
        case .down:
            for col in 0..<gridSize {
                var column = (0..<gridSize).map { grid[$0][col] }.reversed()
                let (combined, score) = combineTiles(line: Array(column))
                let newColumn = Array(combined.reversed())
                for row in 0..<gridSize {
                    if grid[row][col] != newColumn[row] {
                        moved = true
                        grid[row][col] = newColumn[row]
                    }
                }
                addedScore += score
            }
        }
        if moved {
            self.score += addedScore
            addRandomTile()
            checkGameState()
        }
    }
    
    // 合併 tiles 並計算得分
    func combineTiles(line: [Int]) -> ([Int], Int) {
        var newLine = line.filter { $0 != 0 }
        var addedScore = 0
        var idx = 0
        while idx < newLine.count - 1 {
            if newLine[idx] == newLine[idx + 1] {
                newLine[idx] *= 2
                addedScore += newLine[idx]
                newLine[idx + 1] = 0
                // 判斷是否勝利
                if newLine[idx] == 2048 {
                    hasWon = true
                }
                idx += 2
            } else {
                idx += 1
            }
        }
        newLine = newLine.filter { $0 != 0 }
        while newLine.count < gridSize {
            newLine.append(0)
        }
        return (newLine, addedScore)
    }
    
    // 檢查遊戲狀態
    func checkGameState() {
        // 判斷有無空格
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if grid[row][col] == 0 { return }
                if row > 0 && grid[row][col] == grid[row-1][col] { return }
                if row < gridSize-1 && grid[row][col] == grid[row+1][col] { return }
                if col > 0 && grid[row][col] == grid[row][col-1] { return }
                if col < gridSize-1 && grid[row][col] == grid[row][col+1] { return }
            }
        }
        isGameOver = true
    }
}
