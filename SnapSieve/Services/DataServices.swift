//
//  DataServices.swift
//  SnapSieve
//
//  Created by Tejas Badani on 29/01/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Hero
import GoogleSignIn
import SwiftKeychainWrapper
let DB_BASE = Database.database().reference()
let STORAGE_BASE = Storage.storage().reference()
let KEY_UID = "uid"
let KEY_NAME = "name"
class DataServices{
    static let ds = DataServices()
    private var _REF_BASE = DB_BASE
    
    var REF_BASE : DatabaseReference{
        return _REF_BASE
    }
    private var _REF_USERS = DB_BASE.child("users")
    var REF_USERS : DatabaseReference{
        return _REF_USERS
    }
    //DB_BASE refers to the title of the database
    private var _REF_POST = DB_BASE.child("posts")
    
    private var _REF_REPORTS = DB_BASE.child("Reports")
    
    //Storage References
    private var _REF_POST_IMAGES = STORAGE_BASE.child("post-pics")
    
    private var _REF_POST_ID = DB_BASE.child("postIDs")
    var REF_POSTS : DatabaseReference{
        return _REF_POST
    }
    var REF_REPORTS : DatabaseReference{
        return _REF_REPORTS
    }
    var REF_POST_ID : DatabaseReference{
        return _REF_POST_ID
    }
    var REF_POST_IMAGES : StorageReference{
        return _REF_POST_IMAGES
    }
    
    var REF_CURRENT_USER : DatabaseReference{
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        var user  = DatabaseReference()
        if let id = uid {
            print("ID \(id)")
            user = REF_USERS.child(id)
            
        }
        return user
        
    }
    var CURRENT_USER_NAME : String{
        let name = KeychainWrapper.standard.string(forKey: KEY_NAME)
        var fullName : String!
        if let nm = name {
            fullName = nm
        }
        return fullName
    }
    
    
    func createFirebaseUser(uid : String , userData : Dictionary<String,String>){
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    
}

