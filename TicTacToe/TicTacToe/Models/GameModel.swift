//

import Foundation

enum Player {
    case x, o
}

struct Cell {
    let id: Int
    var player: Player?
}

struct GameModel {
    var board: [Cell] = (0..<9).map { Cell(id: $0, player: nil) }
    
    mutating func makeMove(at index: Int, player: Player) {
        guard board[index].player == nil else { return }
        board[index].player = player
    }
}
