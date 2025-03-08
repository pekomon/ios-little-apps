//

import SwiftUI

class GameViewModel: ObservableObject {
    @Published private(set) var game = GameModel()
    @Published var currentPlayer: Player = .x
    @Published var winner: Player?
    @Published var winningCells: [Int] = []
    @Published var showWinAlert = false
    @Published var winnerMessage = ""
    
    func makeMove(at index: Int) {
        guard game.board[index].player == nil, winner == nil else { return }
        
        game.makeMove(at: index, player: currentPlayer)
        if checkWin(for: currentPlayer) {
            winner = currentPlayer
        } else {
            currentPlayer = (currentPlayer == .x) ? .o : .x
        }
        objectWillChange.send()
    }
    
    func restartGame() {
        game = GameModel()
        currentPlayer = .x
        winner = nil
        winningCells = []
    }
    
    private func checkWin(for player: Player) -> Bool {
        let winningCombinations: [[Int]] = [
            [0, 1, 2],
            [3, 4, 5],
            [6, 7, 8],
            [0, 3, 6],
            [1, 4, 7],
            [2, 5, 8],
            [0, 4, 8],
            [2, 4, 6]
        ]
        
        for combo in winningCombinations {
            if combo.allSatisfy({ game.board[$0].player == player}) {
                winningCells = combo
                winnerMessage = "\(player.symbol) wins!"
                showWinAlert = true
                return true
            }
        }
        
        return false
    }
}
