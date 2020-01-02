//
//  MinimaxAI.swift
//  Connect Four
//
//  Created by Sumu Pitchayan on 12/29/19.
//  Copyright © 2019 Sumu Pitchayan. All rights reserved.
//

import Foundation

class MinimaxAI: AIPlayer {
    
    var depth: Int = 3
    
    override func makeDecision(board: Board) -> Int {
//        let col = minimax(board: board, depth: self.depth, isMaximPlayer: true).0!
        let prunCol = minimaxPruned(board: board, depth: self.depth, alpha: Int.min, beta: Int.max, isMaximPlayer: true).0!
        return prunCol
    }
    
    // Alpha-Beta pruning optimizes minimax algorithm
    func minimaxPruned(board: Board, depth: Int, alpha: Int, beta: Int, isMaximPlayer: Bool) -> (Int?, Int) {
        let validCols = board.getAvailableCols()
        
        if depth == 0 || isTerminalNode(board: board) {
            
            if isTerminalNode(board: board) {
                
                let lastMove: BoardPosition = board.moveHistory.last!
                if let win = board.checkWin(row: lastMove.row, col: lastMove.col, token: lastMove.val) {
                    if win[0].val == self.token { // If AI wins
                        return (nil, 100000000000)
                    } else { // If opponent wins
                        return (nil, -100000000000)
                    }
                } else {
                    return (nil, 0)
                }
                
            } else { // Depth is zero
                return (validCols[Int.random(in: 0..<validCols.count)], scorePosition(board: board))
            }
        }

        if isMaximPlayer { // Maximizing player
            var value = Int.min
            var column = validCols[Int.random(in: 0..<validCols.count)]
            for col in validCols {
                var boardTemp = board
                _ = boardTemp.dropToken(col: col, val: self.token)
                
                let newScore = minimaxPruned(board: boardTemp, depth: depth-1, alpha: alpha, beta: beta, isMaximPlayer: false).1
                if newScore > value {
                    value = newScore
                    column = col
                }
                
                // A/B  Pruning:
                let updatedAlpha = max(alpha, value)
                if updatedAlpha >= beta {
                    break
                }
            }
            return (column, value)
        } else { // Minimizing player
            var value = Int.max
            var column = validCols[Int.random(in: 0..<validCols.count)]
            
            for col in validCols {
                var boardTemp = board
                _ = boardTemp.dropToken(col: col, val: .red)
                
                let newScore = minimaxPruned(board: boardTemp, depth: depth-1, alpha: alpha, beta: beta, isMaximPlayer: true).1
                if newScore < value {
                    value = newScore
                    column = col
                }
                
                // A/B Pruning:
                let updatedBeta = min(beta, value)
                if alpha >= updatedBeta {
                    break
                }
            }
            return (column, value)
        }
    }

    // Returns (Int?, Int) tuple representing (bestCol, bestScore)
    func minimax(board: Board, depth: Int, isMaximPlayer: Bool) -> (Int?, Int) {

        let validCols = board.getAvailableCols()
        
        if depth == 0 || isTerminalNode(board: board) {
            
            if isTerminalNode(board: board) {
                
                let lastMove: BoardPosition = board.moveHistory.last!
                if let win = board.checkWin(row: lastMove.row, col: lastMove.col, token: lastMove.val) {
                    if win[0].val == self.token { // If AI wins
                        return (nil, 100000000000)
                    } else { // If opponent wins
                        return (nil, -100000000000)
                    }
                } else {
                    return (nil, 0)
                }
                
            } else { // Depth is zero
                return (validCols[Int.random(in: 0..<validCols.count)], scorePosition(board: board))
            }
        }

        if isMaximPlayer { // Maximizing player
            var value = Int.min
            var column = validCols[Int.random(in: 0..<validCols.count)]
            for col in validCols {
                var boardTemp = board
                _ = boardTemp.dropToken(col: col, val: self.token)
                
                let newScore = minimax(board: boardTemp, depth: depth-1, isMaximPlayer: false).1
                if newScore > value {
                    value = newScore
                    column = col
                }
            }
            return (column, value)
        } else { // Minimizing player
            var value = Int.max
            var column = validCols[Int.random(in: 0..<validCols.count)]
            
            for col in validCols {
                var boardTemp = board
                _ = boardTemp.dropToken(col: col, val: .red)
                
                let newScore = minimax(board: boardTemp, depth: depth-1, isMaximPlayer: true).1
                if newScore < value {
                    value = newScore
                    column = col
                }
            }
            return (column, value)
        }
    }
    
    // Returns T/F if the board has been won or drawn
    func isTerminalNode(board: Board) -> Bool {
        // Check for Win:
        if let lastMove: BoardPosition = board.moveHistory.last {
            if board.checkWin(row: lastMove.row, col: lastMove.col, token: lastMove.val) != nil {
                return true
            }
        }
        
        // Checks for Draw:
        if board.boardIsFull() {
            return true
        }
        return false
    }

    // Returns an Int value score of the board based on diff diagonals/lines
    func scorePosition(board: Board) -> Int {
       
        var score = 0
        
        // Score Center column
        let centerCol = board.getLine(row: 0, col: Int(board.cols/2), xStep: 0, yStep: 1)
        var centerCount = 0
        for bp in centerCol {
            if bp.val == self.token {
                centerCount += 1
            }
        }
        score += centerCount * 3

        // Score Horizontal
        for r in 0..<board.rows {
            let rowArr = board.getLine(row: r, col: 0, xStep: 1, yStep: 0)
            for c in 0...board.cols-board.connect {
                let window = Array(rowArr[c..<c+board.connect])
                score += evaluateWindow(window: window, tokenVal: self.token)
            }
        }
        
        // Score Vertical
        for c in 0..<board.cols {
            let colArr = board.getLine(row: 0, col: c, xStep: 0, yStep: 1)
            for r in 0...board.rows-board.connect {
                let window = Array(colArr[r..<r+board.connect])
                score += evaluateWindow(window: window, tokenVal: self.token)
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
                    score += evaluateWindow(window: window, tokenVal: self.token)
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
                    score += evaluateWindow(window: window, tokenVal: self.token)
                    i += 1
                    j += 1
                }
            }
        }

        return score
    }

    // Returns Int score based of a BoardPosition window (of length four)
    func evaluateWindow(window: [BoardPosition], tokenVal: TokenColor) -> Int {
        // Counts how many tokens of each type are in the window
        var counts: [TokenColor : Int] = [:]
        for item in window {
            counts[item.val] = (counts[item.val] ?? 0) + 1
        }

        var score: Int = 0

        if counts[tokenVal] == 4 {
            score += 100
        } else if counts[tokenVal] == 3 && counts[.none] == 1 {
            score += 5
        } else if counts[tokenVal] == 2 && counts[.none] == 2 {
            score += 2
        }
        
        if counts[.none] == 1 {
            if counts[tokenVal] == nil {
                score -= 4
            }
        }
        
        return score
    }
    
    // Simple decider (no minimax recursion) picks the best move based on available cols
    func pickBestMove(board: Board, curToken: TokenColor) -> Int {
        let randIndex = Int.random(in: 0..<board.getAvailableCols().count)
        
        var bestCol = board.getAvailableCols()[randIndex]
        var bestScore = Int.min
        var curScore = Int.min
        
        for col in board.getAvailableCols() {
            var boardTemp = board
            _ = boardTemp.dropToken(col: col, val: token)

            curScore = scorePosition(board: boardTemp)
            if curScore >= bestScore {
                bestScore = curScore
                bestCol = col
            }
        }
        return bestCol
    }
    
}
