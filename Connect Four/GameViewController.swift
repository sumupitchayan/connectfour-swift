//
//  ViewController.swift
//  Connect Four
//
//  Created by Sumu Pitchayan on 12/17/19.
//  Copyright © 2019 Sumu Pitchayan. All rights reserved.
//

import UIKit

/*
 GameViewController class handles the controls for UI and user input.
 
 It conforms to the GameViewDelegat protocol by implementing the drawToken() method
 */
class GameViewController: UIViewController, GameViewDelegate {

    var game: Game!
    var tokenImageViews = [UIImageView]()
    var darkRed: UIColor!
    var darkYellow: UIColor!
    
    // IBOutlet connections
    @IBOutlet weak var gameStatusLabel: UILabel!
    @IBOutlet weak var gridImageView: UIImageView!
    @IBOutlet weak var emoji1Label: UILabel!
    @IBOutlet weak var emoji2Label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        game.gameViewDelegate = self
                
        // Adds tap gesture recognizer to the Grid Image View
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameViewController.gridTapped(recognizer:)))
        gridImageView.isUserInteractionEnabled = true
        gridImageView.addGestureRecognizer(tapRecognizer)
        
        // Begins the game if the starting player is AI
        game.continueGame()
        
        // Updates the UI
        updateUI()
    }
    
    //MARK: - IB Actions
    
    // Creates a new game by going back to Home VC
    @IBAction func newGameButtonTapped(_ sender: Any) {
        clearTokens(time: 0.5)
        // Waits 1 second for animation to finish to dismiss view controller
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    // Resets the current game
    @IBAction func resetButtonTapped(_ sender: Any) {
        clearTokens(time: 1.0)
        game.reset()
        updateUI()
    }
    
    // Called when the grid image view is tappeed on
    @objc func gridTapped(recognizer: UITapGestureRecognizer) {
        let xloc = recognizer.location(in: gridImageView).x
        let width = gridImageView.frame.width
        // Gets the column value of where the grid was tapped
        let col: Int = Int((xloc / width) * CGFloat(game.cols))
        
        // Makes a game move only when the current player is not an AI
        if game.isValidMove(col: col, player: game.curPlayer) {
            if let _ = game.curPlayer as? AIPlayer {
                return
            } else {
                game.makeMove(col: col, player: game.curPlayer)
            }
        }
    }
    
    //MARK: - UI Update Methods
    
    // Clears all tokens off of the screen and empties the instance array
    func clearTokens(time: Double) {
        for i in (0..<tokenImageViews.count).reversed() {
            let token = tokenImageViews[i]
            animateClearingToken(token: token, time: time)
            tokenImageViews.remove(at: i)
        }
    }
    
    // Animates individual tokens flying back up off of the screen when cleared
    func animateClearingToken(token: UIImageView, time: Double) {
        UIView.animate(withDuration: time, animations: {
            let oldFrame = token.frame
                   token.frame = CGRect(x: oldFrame.minX, y: -200, width: oldFrame.width, height: oldFrame.height)
        }) { (success) in
            if success {
                // Removes the imageview from the view
                token.removeFromSuperview()
            }
        }
    }
    
    // Updates the Game Status label after each turn
    func updateUI() {
        switch(game.winners.count) {
        case 0:
            gameStatusLabel.font = UIFont.boldSystemFont(ofSize: 49)
            gameStatusLabel.text = game.curPlayer.name + "'s turn"
            gameStatusLabel.textColor = (game.curPlayer.token == .red) ? UIColor.red : darkYellow
            updateEmojis()
        case 1:
            gameStatusLabel.font = UIFont.boldSystemFont(ofSize: 70)
            gameStatusLabel.text = "\(game.winners[0].emoji) " + game.winners[0].name + " Wins! 🏆🔥"
        case 2:
            gameStatusLabel.font = UIFont.boldSystemFont(ofSize: 70)
            gameStatusLabel.textColor = UIColor.gray
            gameStatusLabel.text = "It's a Draw!🥈🥈"
        default:
            break
        }
    }
    
    // Updates the player emojis (makes current player emoji larger than the other)
    func updateEmojis() {
        emoji1Label.text = game.player1.emoji
        emoji2Label.text = game.player2.emoji
        
        let toBig: UILabel = (game.curPlayer === game.player1) ? emoji1Label : emoji2Label
        let toSmall: UILabel = (game.curPlayer === game.player1) ? emoji2Label : emoji1Label
        
        let bigFont = UIFont.systemFont(ofSize: 80)
        let smallFont = UIFont.systemFont(ofSize: 40)
        
        toSmall.font = smallFont
        toBig.font = bigFont
    }
    
    //MARK: - Game View Delegate Method
    
    // Called inside the game class whenever a token is dropped
    func drawToken(col: Int, token: TokenColor) {
        // Creates a token as a UIImageView
        let token = UIImageView(image: UIImage(named: token.rawValue))
        token.contentMode = UIView.ContentMode.scaleAspectFit
                        
        let cellW = gridImageView.frame.width / CGFloat(game.cols)
        let cellH = gridImageView.frame.height / CGFloat(game.rows)
        
        let xPos = CGFloat(col) * cellW
        let yPos = gridImageView.frame.maxY - cellH * CGFloat(abs(game.rows - game.board.lastFilledRow(inCol: col)!))
        
        token.frame = CGRect(x: xPos, y: -110, width: cellW, height: cellW)

        // Adds the token to the view above the screen and stores it in instance array
        // We store it in an instance array so that we have access to it for when we want to remove the view
        view.insertSubview(token, belowSubview: gridImageView)
        tokenImageViews.append(token)
        
        // Animates the token falling from above the screen to its position
        UIView.animate(withDuration: 1) {
            token.frame = CGRect(x: xPos, y: yPos, width: cellW, height: cellW)
        }
        
        // Updates UI
        updateUI()
    }

}
