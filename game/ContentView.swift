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

            // 顯示分數
            Text("得分：\(game.score)")
                .font(.headline)
                .padding(.bottom, 10)

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

            // 遊戲網格
            GridView(game: game)
                .gesture(
                    DragGesture(minimumDistance: 30)
                        .onEnded { value in
                            if game.isGameOver || game.hasWon {
                                return
                            }

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

            // 回上一動作按鈕
            Button("回上一動作") {
                game.undo()
            }
            .font(.title)
            .padding()
            .disabled(!game.canUndo) // 沒有歷史時禁用

            // 重新開始按鈕
            Button("Restart") {
                game.restart()
            }
            .font(.title)
            .padding()
            .disabled(game.isGameOver == false && game.hasWon == false)
            .background(Color(UIColor.systemGray6))
            .edgesIgnoringSafeArea(.all)
        }
    }
}


// GridView 簡單示範（依你的原本程式碼調整）
struct GridView: View {
    @ObservedObject var game: GameModel
    let gridSize: Int = 4

    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(0..<gridSize, id: \.self) { col in
                        TileView(value: game.grid[row][col])
                    }
                }
            }
        }
        .padding()
    }
}

struct TileView: View {
    let value: Int

    var body: some View {
        ZStack {
            Rectangle()
                .fill(colorForValue(value))
                .cornerRadius(8)
                .frame(width: 70, height: 70)
            if value > 0 {
                Text("\(value)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(textColor(value))
            }
        }
    }

    func colorForValue(_ value: Int) -> Color {
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

    func textColor(_ value: Int) -> Color {
        return value > 4 ? .white : .black
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
