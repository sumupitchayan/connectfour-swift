//
//  HomeViewController.swift
//  Connect Four
//
//  Created by Sumu Pitchayan on 12/19/19.
//  Copyright © 2019 Sumu Pitchayan. All rights reserved.
//

import Foundation
import UIKit

/*
 HomeViewController allows us to setup players and game.
 
 - We can customize player names, type (AI vs regular), and emoji
 */
class HomeViewController: UIViewController, UITextFieldDelegate {
    
    var game: Game!
    
    // IBOutlet variables
    @IBOutlet weak var name1TextField: UITextField!
    @IBOutlet weak var name2TextField: UITextField!
    @IBOutlet weak var emoji1TextField: UITextField!
    @IBOutlet weak var emoji2TextField: UITextField!
    @IBOutlet weak var ai2Switch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        name1TextField.delegate = self
        name2TextField.delegate = self
        
        emoji1TextField.delegate = self
        emoji2TextField.delegate = self
        
        // Tap gesture to dismiss keyboard when tapped on screen
        let removeKeysTapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.dismissKeyboard(recognizer:)))
        view.addGestureRecognizer(removeKeysTapGesture)
    }
    
    //MARK: - IB Actions
    
    @IBAction func ai2SwitchChanged(_ sender: UISwitch) {
        if ai2Switch.isOn {
            emoji2TextField.text = "🤖"
            emoji2TextField.allowsEditingTextAttributes = false
        } else {
            emoji2TextField.text = emoji2TextField.placeholder
            emoji2TextField.allowsEditingTextAttributes = true
        }
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        
        let name1: String = (name1TextField.text != "") ? name1TextField.text! : name1TextField.placeholder!
        let emoji1: String = (emoji1TextField.text?.containsOnlyEmoji ?? true) ? emoji1TextField.text! : emoji1TextField.placeholder!
        
        let name2 = (name2TextField.text != "") ? name2TextField.text! : name2TextField.placeholder!
        let emoji2: String = (emoji2TextField.text?.containsOnlyEmoji ?? true) ? emoji2TextField.text! : emoji2TextField.placeholder!
        
        // Creates Players and Game:
        let p1 = Player(color: .red, name: name1)
        p1.emoji = emoji1
        let p2 = (ai2Switch.isOn) ? MinimaxAI(color: .yellow, name: name2, delay: 1) : Player(color: .yellow, name: name2)
        p2.emoji = emoji2
        game = Game(height: 6, width: 7, connectWin: 4, p1: p1, p2: p2)
        
        performSegue(withIdentifier: "homeToGame", sender: self)
        
    }
    
    //MARK: - Prepare for Segue
    
    // Sets the game variable in the GameViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is GameViewController {
            let vc = segue.destination as? GameViewController
            vc?.game = self.game!
            vc?.darkRed = self.name1TextField.textColor!
            vc?.darkYellow = self.name2TextField.textColor!
        }
    }
    
    //MARK: - Dismiss Keyboard
    
    // Dismisses keyboard
    @objc func dismissKeyboard(recognizer: UITapGestureRecognizer) {
        name1TextField.resignFirstResponder()
        name2TextField.resignFirstResponder()
        emoji1TextField.resignFirstResponder()
        emoji2TextField.resignFirstResponder()
    }
    
    //MARK: - Text Field Delegate Method
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            // For the name textfields:
            textField.text = (textField.text == "") ? textField.placeholder : textField.text
        } else if textField.tag == 1 {
            // For the emoji textfields:
            if !(textField.text?.containsOnlyEmoji ?? true) {
                textField.text = textField.placeholder
            }
        }
    }
    
}

//MARK: - Extensions for Emoji Reading

// (https://stackoverflow.com/questions/52007286/show-random-emoji-inside-a-label-in-tableviewcell)
extension NSObject {

    public var emojiString: String {
        let pointer = Unmanaged.passUnretained(self).toOpaque()
        // You can adjust your range
        //let range = 0x1F600...0x1F64F
        let range = 0x1F300...0x1F3F0
        let index = (pointer.hashValue % range.count)
        let ord = range.lowerBound + index
        guard let scalar = UnicodeScalar(ord) else { return "❓" }
        return String(scalar)
    }

}

// (https://stackoverflow.com/questions/30757193/find-out-if-character-in-string-is-emoji)
extension Character {
    // A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstProperties = unicodeScalars.first?.properties else {
            return false
        }
        return unicodeScalars.count == 1 &&
            (firstProperties.isEmojiPresentation ||
                firstProperties.generalCategory == .otherSymbol)
    }

    // Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool {
        return (unicodeScalars.count > 1 &&
               unicodeScalars.contains { $0.properties.isJoinControl || $0.properties.isVariationSelector })
            || unicodeScalars.allSatisfy({ $0.properties.isEmojiPresentation })
    }

    var isEmoji: Bool {
        return isSimpleEmoji || isCombinedIntoEmoji
    }
}

extension String {
    var isSingleEmoji: Bool {
        return count == 1 && containsEmoji
    }

    var containsEmoji: Bool {
        return contains { $0.isEmoji }
    }

    var containsOnlyEmoji: Bool {
        return !isEmpty && !contains { !$0.isEmoji }
    }

    var emojiString: String {
        return emojis.map { String($0) }.reduce("", +)
    }

    var emojis: [Character] {
        return filter { $0.isEmoji }
    }

    var emojiScalars: [UnicodeScalar] {
        return filter{ $0.isEmoji }.flatMap { $0.unicodeScalars }
    }
}
