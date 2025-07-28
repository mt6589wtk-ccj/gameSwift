import Foundation
import Combine

class GameModel: ObservableObject {
    // 遊戲的 4x4 格子，每個格子儲存一個數字
    @Published var grid: [[Int]]
    
    // 遊戲是否結束
    @Published var isGameOver: Bool
    // 遊戲是否勝利
    @Published var hasWon: Bool
    
    let gridSize: Int = 4 // 4x4的網格
    
    init() {
        // 初始化 grid 為 4x4 大小，預設為 0
        self.grid = Array(repeating: Array(repeating: 0, count: gridSize), count: gridSize)
        self.isGameOver = false
        self.hasWon = false
        startGame()
    }
    
    // 開始新遊戲
    func startGame() {
        self.isGameOver = false
        self.hasWon = false
        grid = Array(repeating: Array(repeating: 0, count: gridSize), count: gridSize)
        addRandomTile()
        addRandomTile()
    }
    
    // 重啟遊戲
    func restart() {
        self.isGameOver = false
        self.hasWon = false
        startGame()
    }
    
    // 隨機在格子中放置 2 或 4
    func addRandomTile() {
        var emptyTiles: [(Int, Int)] = []
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if grid[row][col] == 0 {
                    emptyTiles.append((row, col))
                }
            }
        }
        
        if !emptyTiles.isEmpty {
            let randomTile = emptyTiles.randomElement()!
            let (row, col) = randomTile
            grid[row][col] = [2, 4].randomElement()!
        }
    }
    
    // 處理移動邏輯
    func moveTiles(direction: Direction) {
        guard !isGameOver else { return }

        let originalGrid = grid  // 保存原始狀態
        
        switch direction {
        case .up:
            moveUp()
        case .down:
            moveDown()
        case .left:
            moveLeft()
        case .right:
            moveRight()
        }
        
        // 只有當網格內容有變動時才新增方塊
        if !gridsAreEqual(grid, originalGrid) {
            addRandomTile()
            checkGameOver()
        }
    }

    
    // 向上移動
    private func moveUp() {
        for col in 0..<gridSize {
            var newColumn: [Int] = grid.map { $0[col] }.filter { $0 != 0 }
            var mergedColumn: [Int] = []
            
            var i = 0
            while i < newColumn.count {
                if i + 1 < newColumn.count && newColumn[i] == newColumn[i + 1] {
                    mergedColumn.append(newColumn[i] * 2)
                    i += 2
                } else {
                    mergedColumn.append(newColumn[i])
                    i += 1
                }
            }
            
            // 填充剩餘的零
            while mergedColumn.count < gridSize {
                mergedColumn.append(0)
            }
            
            // 更新列到網格
            for row in 0..<gridSize {
                grid[row][col] = mergedColumn[row]
            }
        }
    }
    
    // 向下移動
    private func moveDown() {
        for col in 0..<gridSize {
            var newColumn: [Int] = grid.map { $0[col] }.filter { $0 != 0 }.reversed()
            var mergedColumn: [Int] = []
            
            var i = 0
            while i < newColumn.count {
                if i + 1 < newColumn.count && newColumn[i] == newColumn[i + 1] {
                    mergedColumn.append(newColumn[i] * 2)
                    i += 2
                } else {
                    mergedColumn.append(newColumn[i])
                    i += 1
                }
            }
            
            // 填充剩餘的零
            while mergedColumn.count < gridSize {
                mergedColumn.append(0)
            }
            
            // 更新列到網格
            for row in 0..<gridSize {
                grid[row][col] = mergedColumn.reversed()[row]
            }
        }
    }
    
    // 向左移動
    private func moveLeft() {
        for row in 0..<gridSize {
            var newRow: [Int] = grid[row].filter { $0 != 0 }
            var mergedRow: [Int] = []
            
            var i = 0
            while i < newRow.count {
                if i + 1 < newRow.count && newRow[i] == newRow[i + 1] {
                    mergedRow.append(newRow[i] * 2)
                    i += 2
                } else {
                    mergedRow.append(newRow[i])
                    i += 1
                }
            }
            
            // 填充剩餘的零
            while mergedRow.count < gridSize {
                mergedRow.append(0)
            }
            
            grid[row] = mergedRow
        }
    }
    
    // 向右移動
    private func moveRight() {
        for row in 0..<gridSize {
            var newRow: [Int] = grid[row].filter { $0 != 0 }.reversed()
            var mergedRow: [Int] = []
            
            var i = 0
            while i < newRow.count {
                if i + 1 < newRow.count && newRow[i] == newRow[i + 1] {
                    mergedRow.append(newRow[i] * 2)
                    i += 2
                } else {
                    mergedRow.append(newRow[i])
                    i += 1
                }
            }
            
            // 填充剩餘的零
            while mergedRow.count < gridSize {
                mergedRow.append(0)
            }
            
            grid[row] = mergedRow.reversed()
        }
    }
    
    private func gridsAreEqual(_ a: [[Int]], _ b: [[Int]]) -> Bool {
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if a[row][col] != b[row][col] {
                    return false
                }
            }
        }
        return true
    }

    // 檢查遊戲結束或勝利
    func checkGameOver() {
        if hasWon {
            return  // 如果已經獲勝，則不再檢查結束
        }
        
        // 檢查是否有2048
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if grid[row][col] == 2048 {
                    hasWon = true
                    return
                }
            }
        }
        
        // 檢查是否有可以移動或合併的格子
        var canMove = false
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if grid[row][col] == 0 {
                    canMove = true
                }
                if col + 1 < gridSize && grid[row][col] == grid[row][col + 1] {
                    canMove = true
                }
                if row + 1 < gridSize && grid[row][col] == grid[row + 1][col] {
                    canMove = true
                }
            }
        }
        
        // 如果沒有空格且無法合併，遊戲結束
        if !canMove {
            isGameOver = true
        }
    }
}

// 用於移動的方向
enum Direction {
    case up, down, left, right
}
