//
//  User.swift
//  SnapSieve
//
//  Created by Tejas Badani on 14/02/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import Foundation
import ZAlertView
import SwiftKeychainWrapper
class User{
    
     var userID : String!
     var votes : Int!
    var totalVotes : Int!
    var previousStatus : String!
    var currentStatus : String!
     var remainingPosts : Int!
    var screenShots : Int = 0
     static let u = User()
    func terminationMessage(){
        let dialog = ZAlertView(title: "Screenshots are not permitted!", message: "You will no longer see posts from this user. Contact SnapSieve at snapsieve.help@gmail.com for more help.", closeButtonText: "Okay", closeButtonHandler: { (alert) in
            //Do nothing
            
            alert.dismissAlertView()
        })
        dialog.show()
        dialog.allowTouchOutsideToDismiss = true
    }
}
