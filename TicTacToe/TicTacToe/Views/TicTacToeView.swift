//
//  ContentView.swift
//  TicTacToe
//

import SwiftUI

struct TicTacToeView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var showWinMessage = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea()
            VStack {
                Text("Tic Tac Toe")
                    .font(.largeTitle)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: 3),
                    spacing: 10
                ) {
                    ForEach(0..<9) { index in
                        Button(action: {
                            withAnimation(.spring()) {
                                viewModel.makeMove(at: index)
                            }
                        }) {
                            Text(viewModel.game.board[index].player?.symbol ?? "")
                                .font(.system(size: 50))
                                .frame(width: 80, height: 80)
                                .background(viewModel.winningCells.contains(index) ? Color.green : Color.white)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                        }
                        .disabled(viewModel.game.board[index].player != nil || viewModel.winner != nil)
                    }
                }
                .padding()
                
                Button("Restart Game", action: viewModel.restartGame)
                    .padding()
                    .background(colorScheme == .dark ? .white : .black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // ✅ Uusi liukuva voittoanimaatio
            if let winner = viewModel.winner {
                VStack {
                    Spacer()
                    Text("\(winner.symbol) wins!")
                        .font(.largeTitle)
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .offset(y: showWinMessage ? 0 : 100)
                        .opacity(showWinMessage ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5), value: showWinMessage)
                    Spacer()
                }
                .onAppear {
                    showWinMessage = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showWinMessage = false
                        }
                    }
                }
            }
        }
    }
}

extension Player {
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
