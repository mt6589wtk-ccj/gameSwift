import SwiftUI

struct ContentView: View {
    @ObservedObject var game = GameModel()
    
    var body: some View {
        VStack {
            Spacer()
            // 顯示標題
            Text("2048")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            // 顯示遊戲結束或勝利的訊息
            if game.isGameOver {
                Text("Game Over")
                    .font(.title)
                    .foregroundColor(.red)
                    .padding()
            } else if game.hasWon {
                Text("You Win!")
                    .font(.title)
                    .foregroundColor(.green)
                    .padding()
            }
            
            // 顯示遊戲網格
            GridView(game: game)
                .gesture(
                    DragGesture(minimumDistance: 30)
                        .onEnded { value in
                            // 如果遊戲結束或已經贏了，不再處理手勢
                            if game.isGameOver || game.hasWon {
                                return
                            }
                            
                            // 判斷是水平滑動還是垂直滑動
                            if abs(value.translation.width) > abs(value.translation.height) {
                                if value.translation.width > 0 {
                                    game.moveTiles(direction: .right)
                                } else {
                                    game.moveTiles(direction: .left)
                                }
                            } else {
                                if value.translation.height > 0 {
                                    game.moveTiles(direction: .down)
                                } else {
                                    game.moveTiles(direction: .up)
                                }
                            }
                        }
                )
            
            Spacer()
            
            // 顯示重啟遊戲按鈕
            Button("Restart") {
                game.restart()
            }
            .font(.title)
            .padding()
            .disabled(game.isGameOver == false && game.hasWon == false)  // 禁用按鈕，如果遊戲還在進行中
        }
        .background(Color(UIColor.systemGray6))
        .edgesIgnoringSafeArea(.all)
    }
}

struct GridView: View {
    @ObservedObject var game: GameModel
    
    let gridSize: Int = 4
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(0..<gridSize, id: \.self) { col in
                        // 顯示每個格子的數字
                        Text(self.game.grid[row][col] == 0 ? "" : "\(self.game.grid[row][col])")
                            .frame(width: 70, height: 70)
                            .background(self.cellColor(self.game.grid[row][col]))
                            .cornerRadius(10)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(self.textColor(self.game.grid[row][col]))
                    }
                }
            }
        }
        .padding(20)
    }
    
    // 根據數字大小設置顏色
    private func cellColor(_ value: Int) -> Color {
        switch value {
        case 2: return .yellow
        case 4: return .orange
        case 8: return .red
        case 16: return .purple
        case 32: return .blue
        case 64: return .green
        case 128: return .brown
        case 256: return .pink
        case 512: return .cyan
        case 1024: return .teal
        case 2048: return .indigo
        default: return .gray
        }
    }
    
    // 根據數字的大小選擇文本顏色
    private func textColor(_ value: Int) -> Color {
        return value > 4 ? .white : .black
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
