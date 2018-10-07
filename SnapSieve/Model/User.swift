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
    init(){
        //Nothing
    }
     static let u = User()
    private var _userName : String!
    private var _userURL : String!
    private var _status : String!
    private var _type : String!
    private var _ID : String!
    var user : String{
        return _userName
    }
    var userURL : String{
        return _userURL
    }
    var status : String{
        return _status
    }
    var type : String{
        return _type
    }
    var ID : String{
        return _ID
    }
    init(userName: String , profileImageURL : String , status : String , type : String,ID : String) {
        _userName = userName
        _userURL = profileImageURL
        _status = status
        _type = type
        _ID = ID
    }
    func terminationMessage(){
        let dialog = ZAlertView(title: "Screenshots are not permitted!", message: "You will no longer see posts from this user. Contact SnapSieve at snapsieve.help@gmail.com for more help.", closeButtonText: "Okay", closeButtonHandler: { (alert) in
            //Do nothing
            
            alert.dismissAlertView()
        })
        dialog.show()
        dialog.allowTouchOutsideToDismiss = true
    }
}
