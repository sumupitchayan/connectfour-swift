//
//  Board.swift
//  Connect Four
//
//  Created by Sumu Pitchayan on 12/17/19.
//  Copyright © 2019 Sumu Pitchayan. All rights reserved.
//

import Foundation

// TokenColor enum represents the contents of the Board
enum TokenColor: String {
    case red = "RedToken"
    case yellow = "YellowToken"
    case none
}

/*
 Board class represents the 2D grid used in the connect game.
 It contains TokenColor enum objects
 */
struct Board {
    
    let rows: Int
    let cols: Int
    let connect: Int
    private var grid : [[TokenColor]]
    
    init(height: Int, width: Int, connectWin: Int) {
        rows = height
        cols = width
        connect = connectWin
        grid = Array(repeating: Array(repeating: .none, count: cols), count: rows)
    }
    
    // Subscript accessor allows Board objects to get the grid values (but cannot set them)
    // ex/ grid[row][col] = board[row, col]
    subscript(row: Int, col: Int) -> TokenColor {
        get {
            return grid[row][col]
        }
    }
    
    // Resets the grid to original state of .none TokenColors
    mutating func reset() {
        grid = Array(repeating: Array(repeating: .none, count: cols), count: rows)
    }
    
    // Drops a token to the "lowest" open row in a given column
    // Returns the row (or nil) at which the token was inserted
    mutating func dropToken(col: Int, val: TokenColor) -> Int? {
        if let row = firstAvailRow(inCol: col) {
            grid[row][col] = val
            return row
        }
        return nil
    }
    

    //MARK: - Grid Interpretation Methods
    
    // Returns T/F if a point is in range
    func isInRange(row: Int, col: Int) -> Bool {
        return (0..<rows).contains(row) && (0..<cols).contains(col)
    }
    
    // Returns T/F if the column is full
    func colIsFull(_ col: Int) -> Bool {
        return grid[0][col] != .none
    }
    
    // Returns T/F if the board is full
    func boardIsFull() -> Bool {
        for col in 0..<cols {
            if !colIsFull(col) { return false }
        }
        return true
    }
    
    func getAvailableCols() -> [Int] {
        var avail = [Int]()
        for col in 0..<cols {
            if !colIsFull(col) { avail.append(col) }
        }
        return avail
    }
    
    // Returns the first available row in a column, nil if full
    func firstAvailRow(inCol col: Int) -> Int? {
        for row in (0...rows-1).reversed() {
            if grid[row][col] == .none { return row }
        }
        return nil
    }
    
    // Returns the last filled row in a column, nil if empty
    func lastFilledRow(inCol col: Int) -> Int? {
        for row in (0...rows-1) {
            if grid[row][col] != .none { return row }
        }
        return nil
    }
    
    //MARK: - Win Logic
    
    func checkWin(row: Int, col: Int, token: TokenColor) -> [BoardPosition]? {
        
        // Horizonal Win:
        let horizontalLine = getLine(row: row, col: col, xStep: 1, yStep: 0)
        if let win = getConnectWin(line: horizontalLine, val: token) {
            return win
        }
        
        
        // Vertical Win:
        let verticalLine = getLine(row: row, col: col, xStep: 0, yStep: 1)
        if let win = getConnectWin(line: verticalLine, val: token) {
            return win
        }

        // Positive diagonal win:
        let posDiagonal = getLine(row: row, col: col, xStep: 1, yStep: 1)
        if let win = getConnectWin(line: posDiagonal, val: token) {
            return win
        }

        // Negative diagonal win:
        let negDiagonal = getLine(row: row, col: col, xStep: 1, yStep: -1)
        if let win = getConnectWin(line: negDiagonal, val: token) {
            return win
        }
        
        return nil
    }
    
    func getConnectWin(line: [BoardPosition], val: TokenColor) -> [BoardPosition]? {
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
        return (maxLineCount.count >= connect) ? maxLineCount : nil
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
        while(isInRange(row: curR, col: curC)) {
            leftSide.append(BoardPosition(row: curR, col: curC, val: grid[curR][curC]))
            curR += yStep
            curC -= xStep
        }
        
        var rightSide = [BoardPosition]()
        curR = row - yStep
        curC = col + xStep
        while(isInRange(row: curR, col: curC)) {
            rightSide.append(BoardPosition(row: curR, col: curC, val: grid[curR][curC]))
            curR -= yStep
            curC += xStep
        }
        
        let initialPos = BoardPosition(row: row, col: col, val: grid[row][col])
        return leftSide.reversed() + [initialPos] + rightSide
    }
    
    //MARK: Print Helper Function
    
    // Print grid function only used in debugging
    func printGrid() {
        for row in 0...rows-1 {
            
            // Gets the current row:
            var curRow = [TokenColor]()
            for col in 0...cols-1 {
                curRow.append(grid[row][col])
            }
            
            // Creates new row with Int values instead of TokenColors
            var curRowInts = [Int]()
            for i in curRow {
                switch(i) {
                case .red:
                    curRowInts.append(1)
                case .yellow:
                    curRowInts.append(2)
                default:
                    curRowInts.append(0)
                }
            }
            print(curRowInts)
        }
    }
    
}

//MARK: - BoardPosition Struct

// BoardPosition object represents point on the board with its TokenColor value
// Used in determining whether or not the game was been won/drawn
struct BoardPosition {
    var row: Int
    var col: Int
    var val: TokenColor
}
