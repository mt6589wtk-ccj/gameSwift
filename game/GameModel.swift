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
    
    // 儲存歷史狀態，最多五筆
    private var history: [(grid: [[Int]], score: Int, isGameOver: Bool, hasWon: Bool)] = []
    
    init() {
        self.grid = Array(repeating: Array(repeating: 0, count: gridSize), count: gridSize)
        self.isGameOver = false
        self.hasWon = false
        self.score = 0
        startGame()
    }
    
    func startGame() {
        self.isGameOver = false
        self.hasWon = false
        self.score = 0
        grid = Array(repeating: Array(repeating: 0, count: gridSize), count: gridSize)
        history.removeAll()
        addRandomTile()
        addRandomTile()
    }
    
    func restart() {
        startGame()
    }
    
    // 將目前狀態儲存到歷史堆疊
    func saveState() {
        let currentGrid = grid.map { $0 }
        history.append((grid: currentGrid, score: score, isGameOver: isGameOver, hasWon: hasWon))
        if history.count > 5 {
            history.removeFirst()
        }
    }
    
    // 讓外部檢查是否能回上一動作（UI用）
    var canUndo: Bool {
        return !history.isEmpty
    }
    
    // 回上一動作
    func undo() {
        guard let previousState = history.popLast() else { return }
        grid = previousState.grid
        score = previousState.score
        isGameOver = previousState.isGameOver
        hasWon = previousState.hasWon
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
        if let randomPos = emptyTiles.randomElement() {
            grid[randomPos.0][randomPos.1] = Int.random(in: 0...9) == 0 ? 4 : 2
        }
    }
    
    // 移動邏輯
    func moveTiles(direction: MoveDirection) {
        // 儲存當前狀態，用於undo
        saveState()
        
        var moved = false
        switch direction {
        case .left:
            for row in 0..<gridSize {
                let (newLine, addedScore) = mergeLine(line: grid[row])
                if newLine != grid[row] {
                    moved = true
                    grid[row] = newLine
                    score += addedScore
                }
            }
        case .right:
            for row in 0..<gridSize {
                let reversed = grid[row].reversed()
                let (newLine, addedScore) = mergeLine(line: Array(reversed))
                let restored = newLine.reversed()
                if Array(restored) != grid[row] {
                    moved = true
                    grid[row] = Array(restored)
                    score += addedScore
                }
            }
        case .up:
            for col in 0..<gridSize {
                var column = [Int]()
                for row in 0..<gridSize {
                    column.append(grid[row][col])
                }
                let (newLine, addedScore) = mergeLine(line: column)
                if newLine != column {
                    moved = true
                    for row in 0..<gridSize {
                        grid[row][col] = newLine[row]
                    }
                    score += addedScore
                }
            }
        case .down:
            for col in 0..<gridSize {
                var column = [Int]()
                for row in 0..<gridSize {
                    column.append(grid[row][col])
                }
                let reversed = column.reversed()
                let (newLine, addedScore) = mergeLine(line: Array(reversed))
                let restored = newLine.reversed()
                if Array(restored) != column {
                    moved = true
                    for row in 0..<gridSize {
                        grid[row][col] = Array(restored)[row]
                    }
                    score += addedScore
                }
            }
        }
        
        if moved {
            addRandomTile()
            checkGameState()
        } else {
            // 如果沒有移動，剛剛存的狀態不算，撤回
            _ = history.popLast()
        }
    }
    
    // 合併一列陣列，回傳新陣列及得分
    func mergeLine(line: [Int]) -> ([Int], Int) {
        var newLine = line.filter { $0 != 0 }
        var addedScore = 0
        var idx = 0
        
        while idx < newLine.count - 1 {
            if newLine[idx] == newLine[idx + 1] {
                newLine[idx] *= 2
                addedScore += newLine[idx]
                newLine.remove(at: idx + 1)
                if newLine[idx] == 2048 {
                    hasWon = true
                }
            }
            idx += 1
        }
        
        while newLine.count < gridSize {
            newLine.append(0)
        }
        
        return (newLine, addedScore)
    }
    
    // 檢查遊戲結束狀態
    func checkGameState() {
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if grid[row][col] == 0 {
                    isGameOver = false
                    return
                }
                if row > 0 && grid[row][col] == grid[row - 1][col] {
                    isGameOver = false
                    return
                }
                if row < gridSize - 1 && grid[row][col] == grid[row + 1][col] {
                    isGameOver = false
                    return
                }
                if col > 0 && grid[row][col] == grid[row][col - 1] {
                    isGameOver = false
                    return
                }
                if col < gridSize - 1 && grid[row][col] == grid[row][col + 1] {
                    isGameOver = false
                    return
                }
            }
        }
        isGameOver = true
    }
}
