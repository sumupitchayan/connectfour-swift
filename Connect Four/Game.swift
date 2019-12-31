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
class Game: NSCopying {
    
    // Game has 2 Players and keeps track of the current player
    let player1: Player
    let player2: Player
    var curPlayer: Player
    
    // Winners array.count is 0 if not won, 1 if won, and 2 (both players) if drawn
    var winners: [Player] = [Player]()
    
    // GameViewDelegate variable
    var gameViewDelegate: GameViewDelegate?
    
    // Board size/win count variables:
    var board: Board
    let connect: Int
    let rows: Int
    let cols: Int
    
    init(height: Int, width: Int, connectWin: Int, p1: Player, p2: Player) {
        
        rows = height
        cols = width
        connect = connectWin
        board = Board(height: height, width: width, connectWin: connectWin)
        
        player1 = p1
        player2 = p2
        curPlayer = player1
    }
    
    // Resets the board, winners tracker and turn tracker variables
    func reset() {
        board.reset()
        winners = [Player]()
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
                let colMove = ai.makeDecision(board: self.board)
                // Delays the AI's move according to its .delay property in seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + ai.delay, execute: {
                    self.makeMove(col: colMove, player: self.curPlayer)
                })
            }
        }
    }
    
    //MARK: - Game Win/Draw Logic
    
    // Updates the winners array instance variable
    func updateGameStatus(row: Int, col: Int, player: Player) {
        
        if board.checkWin(row: row, col: col, token: player.token) != nil {
            winners = [player]
        } else if board.boardIsFull() {
            winners = [player1, player2]
        }
        
    }
    
    //MARK: - NSCopying Protocol
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Game(height: rows, width: cols, connectWin: connect, p1: player1, p2: player2)
        copy.board = self.board
        copy.winners = self.winners
        copy.curPlayer = self.curPlayer
        return copy
    }
    
}
