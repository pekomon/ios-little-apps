//
//  ContentView.swift
//  TicTacToe
//

import SwiftUI

struct TicTacToeView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        VStack {
            Text("Tic Tac Toe")
                .font(.largeTitle)
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 3),
                spacing: 10
            ) {
                ForEach(0..<9) { index in
                    Button(action: { viewModel.makeMove(at: index) }) {
                        Text(viewModel.game.board[index].player?.symbol ?? "")
                            .font(.system(size: 50))
                            .frame(width: 80, height: 80)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                    }
                    .disabled(viewModel.game.board[index].player != nil || viewModel.winner != nil)
                }
            }
            .padding()
            
            if let winner = viewModel.winner {
                Text("Winner is \(winner.symbol)")
                    .font(.title)
                    .padding()
            }
            
            Button("Restart Game", action: viewModel.restartGame)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

private extension Player {
    var symbol: String {
        switch self {
        case .x:
            return "X"
        case .o:
            return "O"
        }
    }
}

#Preview {
    TicTacToeView()
}
