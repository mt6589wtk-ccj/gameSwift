2048 Swift 遊戲
2048 是由 SwiftUI 製作的簡易數字合併遊戲，支援基本操作、分數排行榜，以及回復（Undo）功能（ContentView.swift、GameModel.swift、LeaderboardManager.swift）。

專案特色
完整 2048 遊戲規則，4x4 格子自動新增數字方塊（GameModel.swift）

分數自動計算，達到 2048 即勝利

支援遊戲結束與勝利顯示（ContentView.swift）

提供「回上一動作」功能，可回復至前一個狀態（最多 5 步）（GameModel.swift）

在地排行榜（LeaderboardManager.swift），儲存最高 10 筆分數，重啟遊戲時保留紀錄

操作簡單，支援觸控拖曳（手勢）移動方塊（ContentView.swift）

截圖
<img width="454" height="912" alt="截圖 2025-08-25 上午9 57 35" src="https://github.com/user-attachments/assets/03a6e6a8-70a0-4acf-bf6a-b842e7869527" />


安裝方式
安裝 Xcode（建議 Xcode 13 以上版本）

下載或 clone 本專案

用 Xcode 開啟本資料夾，並直接執行

進入遊戲主畫面即可開始遊玩

主要檔案說明
ContentView.swift ：遊戲主介面與用戶操作。
GameModel.swift ：遊戲邏輯、分數計算、步驟紀錄。
LeaderboardManager.swift ：分數排行榜管理及本地儲存。
gameApp.swift ：App 入口設定。

技術細節
使用 SwiftUI 架構設計 UI 元件，反應式顯示界面狀態（ContentView.swift）
所有數據儲存於本地（UserDefaults）無需雲端帳號（LeaderboardManager.swift）
利用 Combine 與 @Published 保持資料同步（GameModel.swift）
支援 Undo 功能（最多可回溯 5 步）提高遊戲體驗（GameModel.swift）
