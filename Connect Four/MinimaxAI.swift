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
        return pickBestMove(board: board)
//        return 0
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

    func pickBestMove(board: Board) -> Int {
        var bestCol = 0
        var bestScore = Int.min
        var curScore = Int.min
        
        for col in board.getAvailableCols() {
            var boardTemp = board
            boardTemp.dropToken(col: col, val: token)
            curScore = scorePosition(board: boardTemp, curToken: token)

            print(curScore)

            if curScore > bestScore {
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
            for c in 0..<board.rows-board.connect-1 {
                let window = Array(rowArr[c..<c+board.connect])
                score += evaluateWindow(window: window, curToken: curToken)
                print(window.count)
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
        }

//        else if counts[curToken] == 2 && counts[.none] == 2 {
//            score += 2
//        }
//
//        if counts[token] == 0 && counts[.none] == 1 {
//            score -= 80
//        }

        return score
    }
    
}
