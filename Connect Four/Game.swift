//
//  Game.swift
//  Connect Four
//
//  Created by Sumu Pitchayan on 12/17/19.
//  Copyright © 2019 Sumu Pitchayan. All rights reserved.
//

import Foundation

// Used to pass information onto UI component of Game
protocol GameViewDelegate {
    // Function is called inside the game class when a token is added to the board
    func drawToken(col: Int, token: TokenColor)
}

/*
 Game class models a standard connect game and contains the logic
 for player turn switching, checking for wins/draws, and making
 moves.
 */
class Game {
    
    // Game has 2 Players and keeps track of the current player
    let player1: Player
    let player2: Player
    var curPlayer: Player
    
    // Winners array.count is 0 if not won, 1 if won, and 2 (both players) if drawn
    var winners: [Player] = [Player]()
    
    // GameViewDelegate variable
    var gameViewDelegate: GameViewDelegate?
    
    // Board size/win count variables:
    let board: Board
    let connect: Int
    let rows: Int
    let cols: Int
    
    init(height: Int, width: Int, connectWin: Int, p1: Player, p2: Player) {
        
        rows = height
        cols = width
        connect = connectWin
        board = Board(height: height, width: width)
        
        player1 = p1
        player2 = p2
        curPlayer = player1
    }
    
    //MARK: - Main Game Functions
    
    // Checks if a move is valid for a given player
    func isValidMove(col: Int, player: Player) -> Bool {
        /*
         For a move to be valid:
         
         - It must be the given player's turn
         - The column must be within range
         - The game cannot have already been won/drawn
         - The column cannot already be full
         */
        if !(curPlayer === player) { return false }
        if !((0..<cols).contains(col)) { return false }
        if !(winners.count == 0) { return false }
        if (board.firstAvailRow(inCol: col) == nil) { return false }
        
        return true
    }
    
    // Makes a move for a given player and column
    func makeMove(col: Int, player: Player) {

        if isValidMove(col: col, player: player) {
            
            // Drops the token into the board
            let row: Int = board.dropToken(col: col, val: player.token)!
            
            // Checks if the last move was a win or draw
            updateGameStatus(row: row, col: col, player: player)
            
            // Switches the player turn
            curPlayer = (curPlayer === player1) ? player2 : player1
            
            // Calls on the Gave View Delegate
            if let gvd = gameViewDelegate {
                gvd.drawToken(col: col, token: player.token)
            }
            
            // Continues the game (if it is still on)
            continueGame()
        }
    }
    
    // Continues the game cycle (for AI) if it has not already been won/drawn
    func continueGame() {
        if (winners.count == 0) {
            // If the current player is AI, make the AI player move
            if let ai = curPlayer as? AIPlayer {
                let colMove = ai.makeDecision(board: board)
                // Delays the AI's move according to its .delay property in seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + ai.delay, execute: {
                    self.makeMove(col: colMove, player: self.curPlayer)
                })
            }
        }
    }
    
    // Resets the board, winners tracker and turn tracker variables
    func reset() {
        board.reset()
        winners = [Player]()
        curPlayer = player1
    }
    
    //MARK: - Game Win/Draw Logic
    
    // Updates the winners array instance variable
    func updateGameStatus(row: Int, col: Int, player: Player) {
        checkWin(row: row, col: col, player: player)
        if winners.count == 0 {
            checkDraw()
        }
    }
    
    // Draw check: if each column is full
    func checkDraw() {
        for col in 0...board.cols-1 {
            if !board.colIsFull(col: col) { return }
        }
        winners = [player1, player2]
    }
    
    // Win check: if there is a connecting line of connect length
    func checkWin(row: Int, col: Int, player: Player) {
        
        // The starting token color at [row][col]
        let initialToken: TokenColor = board[row, col]
        
        // Horizonal Win:
        let horizontalLine = getLine(row: row, col: col, xStep: 1, yStep: 0)
        if lineIsWin(line: horizontalLine, val: initialToken) {
            winners = [player]
            return
        }
        
        // Vertical Win:
        let verticalLine = getLine(row: row, col: col, xStep: 0, yStep: 1)
        if lineIsWin(line: verticalLine, val: initialToken) {
            winners = [player]
            return
        }

        // Positive diagonal win:
        let posDiagonal = getLine(row: row, col: col, xStep: 1, yStep: 1)
        if lineIsWin(line: posDiagonal, val: initialToken) {
            winners = [player]
            return
        }

        // Negative diagonal win:
        let negDiagonal = getLine(row: row, col: col, xStep: 1, yStep: -1)
        if lineIsWin(line: negDiagonal, val: initialToken) {
            winners = [player]
            return
        }
    }
    
    // Determines if line is a win
    func lineIsWin(line: [BoardPosition], val: TokenColor) -> Bool {
        // Goes through the list of ordered BoardPosition points and finds the longest sublist that have the desired token color.
        // If the maximum sublist is at least the length of the connect win value, it returns True.
        var maxLineCount = [BoardPosition]()
        var tempLineCount = [BoardPosition]()
        for token in line {
            if token.val == val {
                tempLineCount.append(token)
                // Updates the maxLine count
                maxLineCount = (tempLineCount.count >= maxLineCount.count) ? tempLineCount : maxLineCount
            } else {
                tempLineCount = [BoardPosition]()
            }
        }
        return maxLineCount.count >= connect
    }
    
    // Gets a line passing through a specified point
    func getLine(row: Int, col: Int, xStep: Int, yStep: Int) -> [BoardPosition] {
        /*
         Gets a list of BorderPositions on a specified line through the input point at [row][col]
         
         There are four different lines that intersect any given point:
         - Horizontal (the row): xStep = 1, yStep = 0
         - Vertical (the column): xStep = 0, yStep = 0
         - Positive Diagonal: xStep = 1, yStep = 0
         - Negative Diagonal: xStep = 1, yStep = -1
         */
        var leftSide = [BoardPosition]()
        var curR = row+yStep
        var curC = col-xStep
        while((0..<rows).contains(curR) && (0..<cols).contains(curC)) {
            leftSide.append(BoardPosition(row: curR, col: curC, val: board[curR, curC]))
            curR += yStep
            curC -= xStep
        }
        
        var rightSide = [BoardPosition]()
        curR = row - yStep
        curC = col + xStep
        while((0..<rows).contains(curR) && (0..<cols).contains(curC)) {
            rightSide.append(BoardPosition(row: curR, col: curC, val: board[curR, curC]))
            curR -= yStep
            curC += xStep
        }
        
        let initialPos = BoardPosition(row: row, col: col, val: board[row, col])
        return leftSide.reversed() + [initialPos] + rightSide
    }
    
}

// BoardPosition object represents point on the board with its TokenColor value
// Used in determining whether or not the game was been won/drawn
struct BoardPosition {
    var row: Int
    var col: Int
    var val: TokenColor
}
