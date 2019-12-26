//
//  Player.swift
//  Connect Four
//
//  Created by Sumu Pitchayan on 12/17/19.
//  Copyright © 2019 Sumu Pitchayan. All rights reserved.
//

import Foundation

/*
 Player class models any connect game player.
 It takes in a TokenColor and name (String) variable.
 */
class Player {
    
    var name: String
    let token: TokenColor
    var emoji: String = ""
    
    init(color: TokenColor, name: String) {
        self.name = name
        self.token = color
    }
    
}
