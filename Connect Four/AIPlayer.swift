//
//  AIPlayer.swift
//  Connect Four
//
//  Created by Sumu Pitchayan on 12/19/19.
//  Copyright © 2019 Sumu Pitchayan. All rights reserved.
//

import Foundation

/*
 AI Player models a connect player that does not take in user input.
 The makeDecision(board:) method decides where to make a move and takes in
 the game board as an input.
 
 -> To create a smarter/more sophisticated AI player, all we would need to do
 is create a subclass of AIPlayer and override its makeDecision(board:) method
 with a more complex algorithm.
 */
class AIPlayer: Player {

    // AI player movement will be delayed by this many seconds
    var delay: Double = 2
    
    init(color: TokenColor, name: String, delay: Double) {
        super.init(color: color, name: name)
        self.delay = delay
    }
    
    // Simplest make decision function choses a random column
    func makeDecision(board: Board) -> Int {
        let randCol = Int.random(in: 0..<board.cols)
        if !board.colIsFull(randCol) {
            return randCol
        } else {
            let randIndex = Int.random(in: 0..<board.getAvailableCols().count)
            return board.getAvailableCols()[randIndex]
        }
    }
    
}
