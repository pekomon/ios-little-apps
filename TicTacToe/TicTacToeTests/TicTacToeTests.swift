//
//  TicTacToeTests.swift
//  TicTacToeTests
//
//  Created by Pekomon on 2.3.2025.
//

import Testing
@testable import TicTacToe

struct TicTacToeTests {

    @Test func gameStartsWithNineEmptyCells() async throws {
        let game = GameModel()

        #expect(game.board.count == 9)
        #expect(game.board.allSatisfy { $0.player == nil })
    }

    @Test func makeMoveMarksSelectedCell() async throws {
        var game = GameModel()

        game.makeMove(at: 4, player: .x)

        #expect(game.board[4].player == .x)
    }

    @Test func makeMoveDoesNotOverwriteOccupiedCell() async throws {
        var game = GameModel()

        game.makeMove(at: 4, player: .x)
        game.makeMove(at: 4, player: .o)

        #expect(game.board[4].player == .x)
    }

    @Test func winningSequenceSetsWinnerAndWinningCells() async throws {
        let viewModel = GameViewModel()

        viewModel.makeMove(at: 0) // X
        viewModel.makeMove(at: 3) // O
        viewModel.makeMove(at: 1) // X
        viewModel.makeMove(at: 4) // O
        viewModel.makeMove(at: 2) // X wins

        #expect(viewModel.winner == .x)
        #expect(viewModel.winningCells == [0, 1, 2])
    }

    @Test func restartGameClearsBoardAndWinnerState() async throws {
        let viewModel = GameViewModel()

        viewModel.makeMove(at: 0)
        viewModel.makeMove(at: 3)
        viewModel.makeMove(at: 1)
        viewModel.makeMove(at: 4)
        viewModel.makeMove(at: 2)

        viewModel.restartGame()

        #expect(viewModel.currentPlayer == .x)
        #expect(viewModel.winner == nil)
        #expect(viewModel.winningCells.isEmpty)
        #expect(viewModel.game.board.allSatisfy { $0.player == nil })
    }

}
