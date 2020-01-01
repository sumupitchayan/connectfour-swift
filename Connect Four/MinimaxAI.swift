//
//  MinimaxAI.swift
//  Connect Four
//
//  Created by Sumu Pitchayan on 12/29/19.
//  Copyright © 2019 Sumu Pitchayan. All rights reserved.
//

import Foundation

class MinimaxAI: AIPlayer {
        
    override func makeDecision(board: Board) -> Int {
//        let bestCol = pickBestMove(game: game)
        return pickBestMove(board: board, curToken: token)
    }
    
    func isTerminalNode(game: Game) -> Bool {
        return game.winners.count > 0
    }

    func minimax(game: Game, depth: Int, isMaximPlayer: Bool) -> Int {

        if depth == 0 || isTerminalNode(game: game) {
            if isTerminalNode(game: game) {
                if game.winners.count == 1 { // Maximizing player wins
                    if game.winners[0] === self {
                        return 100000000000
                    } else { // Opponent wins
                        return -100000000000
                    }
                } else { // It is a draw
                    return 0
                }
            } else { // Depth is zero
                // return scorePosition()
            }
        }

        // Maximizing player
        if isMaximPlayer {
            var value = Int.min
        }

        // Minimizing player
        else {

        }

        return 0
    }

    func pickBestMove(board: Board, curToken: TokenColor) -> Int {
        let randIndex = Int.random(in: 0..<board.getAvailableCols().count)
        
        var bestCol = board.getAvailableCols()[randIndex]
        var bestScore = Int.min
        var curScore = Int.min
        
        for col in board.getAvailableCols() {
            var boardTemp = board
            _ = boardTemp.dropToken(col: col, val: token)

            curScore = scorePosition(board: boardTemp, curToken: curToken)
//            print("cur col = \(col)")
//            print(curScore)

//            print("Cur score: = \(curScore)")
            
            if curScore >= bestScore {
                bestScore = curScore
                bestCol = col
            }
        }
        return bestCol
    }

    func scorePosition(board: Board, curToken: TokenColor) -> Int {
        var score = 0

        // Score Horizontal
        for r in 0..<board.rows {
            let rowArr = board.getLine(row: r, col: 0, xStep: 1, yStep: 0)
            for c in 0...board.cols-board.connect {
                let window = Array(rowArr[c..<c+board.connect])
                score += evaluateWindow(window: window, curToken: curToken)
            }
        }
        
        // Score Vertical
        for c in 0..<board.cols {
            let colArr = board.getLine(row: 0, col: c, xStep: 0, yStep: 1)
            for r in 0...board.rows-board.connect {
                let window = Array(colArr[r..<r+board.connect])
                score += evaluateWindow(window: window, curToken: curToken)
            }
        }
        
        // Score Positive Diagonal
        for c in 0..<board.cols {
            let posDiagArr = board.getLine(row: 2, col: c, xStep: 1, yStep: 1)
            if posDiagArr.count >= board.connect {
                var i = 0
                var j = board.connect - 1
                
                while(j < posDiagArr.count) {
                    let window = Array(posDiagArr[i...j])
                    score += evaluateWindow(window: window, curToken: curToken)
                    i += 1
                    j += 1
                }
            }
        }
        
        // Score Negative Diagonal
        for c in 0..<board.cols {
            let posDiagArr = board.getLine(row: 2, col: c, xStep: 1, yStep: -1)
            if posDiagArr.count >= board.connect {
                var i = 0
                var j = board.connect - 1
                
                while(j < posDiagArr.count) {
                    let window = Array(posDiagArr[i...j])
                    score += evaluateWindow(window: window, curToken: curToken)
                    i += 1
                    j += 1
                }
            }
        }

        return score
    }

    func evaluateWindow(window: [BoardPosition], curToken: TokenColor) -> Int {
        // Counts how many tokens of each type are in the window
        var counts: [TokenColor : Int] = [:]
        for item in window {
            counts[item.val] = (counts[item.val] ?? 0) + 1
        }

        var score: Int = 0

        if counts[curToken] == 4 {
            score += 100
        } else if counts[curToken] == 3 && counts[.none] == 1 {
            score += 10
        } else if counts[curToken] == 2 && counts[.none] == 2 {
            score += 5
        }
        
        if counts[curToken] == 0 && counts[.none] == 1 {
            score -= 80
        }
        

//        else if counts[curToken] == 2 && counts[.none] == 2 {
//            score += 2
//        } else if counts[curToken] == 1 {
//            score += 7
//        }
//
//        if counts[token] == 0 && counts[.none] == 1 {
//            score -= 80
//        }

        return score
    }
    
}
