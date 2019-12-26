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
class Board {
    
    let rows: Int
    let cols: Int
    private var grid : [[TokenColor]]
    
    init(height: Int, width: Int) {
        rows = height
        cols = width
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
    func reset() {
        grid = Array(repeating: Array(repeating: .none, count: cols), count: rows)
    }
    
    // Drops a token to the "lowest" open row in a given column
    // Returns the row (or nil) at which the token was inserted
    func dropToken(col: Int, val: TokenColor) -> Int? {
        if let row = firstAvailRow(inCol: col) {
            grid[row][col] = val
            return row
        }
        return nil
    }
    
    //MARK: - Grid Interpretation Methods
    
    // Returns T/F if the column is full
    func colIsFull(col: Int) -> Bool {
        return grid[0][col] != .none
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
