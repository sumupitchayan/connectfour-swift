//
//  Connect_FourTests.swift
//  Connect FourTests
//
//  Created by Sumu Pitchayan on 12/17/19.
//  Copyright © 2019 Sumu Pitchayan. All rights reserved.
//

import XCTest
@testable import Connect_Four

class Connect_FourTests: XCTestCase {
    
    var board: Board!
    var player1: Player!
    var player2: Player!
    var game: Game!
    
    override func setUp() {
        board = Board(height: 6, width: 7, connectWin: 4)
        player1 = Player(color: .red, name: "Sumu")
        player2 = Player(color: .yellow, name: "Andy")
        game = Game(height: 6, width: 7, connectWin: 4, p1: player1, p2: player2)
    }
    
    //MARK: - Game Tests
    
    func testTurnsWork() {
        
        // Test that player 2 (not starting) cannot make a move
        game.makeMove(col: 0, player: player2)
        XCTAssertTrue(game.board.firstAvailRow(inCol: 0) == game.board.rows-1)
        
        // Test that player 1 (starting player) can make a move
        game.makeMove(col: 0, player: player1)
        XCTAssertTrue(game.board[game.rows-1, 0] == player1.token)
        
        // Test that player 1 cannot make a move again
        game.makeMove(col: 0, player: player1)
        
        // Test that player 2 can now move
        game.makeMove(col: 0, player: player2)
        XCTAssertTrue(game.board[game.rows-2, 0] == player2.token)
        
    }
    
    //MARK: - Board Tests: Win Logic
    
    func testHorizontalWinFromLeft() {
        for i in 0...2 {
            game.makeMove(col: i, player: player1)
            game.makeMove(col: i, player: player2)
        }
        game.makeMove(col: 3, player: player1)
        XCTAssertTrue(game.winners.count == 1)
    }
    
    func testHorizontalWinFromRight() {
        for i in (1...3).reversed() {
            game.makeMove(col: i, player: player1)
            game.makeMove(col: i, player: player2)
        }
        game.makeMove(col: 0, player: player1)
        XCTAssertTrue(game.winners.count == 1)
    }
    
    func testVerticalWin() {
        for _ in 0...2 {
            game.makeMove(col: 0, player: player1)
            game.makeMove(col: 1, player: player2)
        }
        game.makeMove(col: 0, player: player1)
        XCTAssertTrue(game.winners.count == 1)
    }
    
    func testDiagonalWin() {
        game.makeMove(col: 0, player: player1)
        game.makeMove(col: 1, player: player2)
        game.makeMove(col: 1, player: player1)
        game.makeMove(col: 2, player: player1)
        game.makeMove(col: 2, player: player2)
        game.makeMove(col: 2, player: player1)
        game.makeMove(col: 3, player: player2)
        game.makeMove(col: 3, player: player1)
        game.makeMove(col: 3, player: player2)
        game.makeMove(col: 3, player: player1)
        game.makeMove(col: 5, player: player2)
        XCTAssertTrue(game.winners.count == 0)
        game.makeMove(col: 2, player: player1)
        XCTAssertTrue(game.winners.count == 1)
    }
    
    func testGetLine() {
        let bottomRow = board.getLine(row: game.rows-1, col: 3, xStep: 1, yStep: 0)
        XCTAssert(bottomRow.count == 7)
        print(bottomRow.count)
    }
    
    //MARK: - Board Tests: General
    
    func testSubscript() {
        XCTAssertTrue(board[0, 0] == .none)
    }

    func testDropToken() {
        XCTAssert(board[board.rows-1, 0] == .none)
        XCTAssert(board.dropToken(col: 0, val: .red) == board.rows-1)
        XCTAssert(board[board.rows-1, 0] == .red)
    }
    
    func testIsInRange() {
        XCTAssertTrue(board.isInRange(row: 0, col: 5))
        XCTAssertFalse(board.isInRange(row: 7, col: 3))
        XCTAssertFalse(board.isInRange(row: 0, col: 7))
        XCTAssertFalse(board.isInRange(row: 7, col: 7))
    }

    func testFirstAvailRow() {
        XCTAssert(board.firstAvailRow(inCol: 0) == board.rows-1)
        XCTAssert(board.dropToken(col: 0, val: .red) == board.rows-1)
        XCTAssert(board.firstAvailRow(inCol: 0) == board.rows-2)

        // Fill up column all the way
        for _ in 0...3 {
            _ = board.dropToken(col: 0, val: .red)
        }
        XCTAssertTrue(board.firstAvailRow(inCol: 0) == 0)
        _ = board.dropToken(col: 0, val: .red)

        XCTAssertNil(board.firstAvailRow(inCol: 0))
    }

    func testColIsFull() {
        XCTAssertFalse(board.colIsFull(0))
        for _ in 0...4 {
            XCTAssertTrue((board.dropToken(col: 0, val: .red) != nil))
        }
        XCTAssertFalse(board.colIsFull(0))
        XCTAssertTrue((board.dropToken(col: 0, val: .red) != nil))
        XCTAssertTrue(board.colIsFull(0))
    }
    
    func testGetAvailableCols() {
        XCTAssertTrue(board.getAvailableCols().count == 7)
        for _ in 0..<6 {
            _ = board.dropToken(col: 0, val: .red)
        }
        XCTAssertTrue(board.getAvailableCols().count == 6)
        XCTAssertFalse(board.getAvailableCols().contains(0))
    }

}
