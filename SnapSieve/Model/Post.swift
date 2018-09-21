//
//  Post.swift
//  SnapSieve
//
//  Created by Tejas Badani on 03/02/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import Foundation
import Firebase
class Post{
    private var _votesImage1: Float!
    private var _votesImage2: Float!
    private var _updateVotesImage1Ref : DatabaseReference!
    private var _updateVotesImage2Ref : DatabaseReference!
    private var _userDidVoteRef : DatabaseReference!
    private var _postID : String!
    private var _isVotingEnabled : Bool!
    private var _username : String!
    private var _caption: String!
    private var _imgURL1 : URL!
    private var _imgURL2 : URL!
    private var _profileURL : String!
    private var _coolCount : Int!
    private var _litCount : Int!
    private var _heartCount : Int!
    private var _flowersCount : Int!
    private var _confusedCount : Int!
    private var _userID : String!
    private var _status : String!
    private var _time : String!
    private var _rating : Float!
    var image1 : UIImage!
    var image2 : UIImage!
    
    var userID : String{
        return _userID
    }
    var coolCount : Int{
        return _coolCount
    }
    var litCount : Int{
        return _litCount
    }
    var heartCount : Int{
        return _heartCount
    }
    var flowerCount : Int{
        return _flowersCount
    }
    var confusedCount : Int{
        return _confusedCount
    }
    
    var votesImage1 : Float{
        return _votesImage1
    }
    var votesImage2 : Float{
        return _votesImage2
    }
    var postID : String{
        return _postID
    }
    var userName : String{
        return _username
    }
    var caption : String{
        return _caption
    }
    var imgURL1 : URL {
        return _imgURL1
    }
    var imgURL2 : URL {
        return _imgURL2
    }
    var profileURL : String{
        return _profileURL
    }
    var status : String{
        return _status
    }
    var time : String{
        return _time
    }
    var rating : Float {
        return _rating
    }
    var isVotingEnabled : Bool!

    init(img1URL : URL , img2URL : URL , votes1: Float , votes2: Float ,postID : String , username : String,caption : String, profileURL : String , coolC : Int , litC : Int , heartC : Int , flowersC : Int , confusedC : Int , userID : String , isVotingEnabled : Bool , stat : String = "",time : String, rating: Float = 0.0) {
        self._votesImage1 = votes1
        self._imgURL1 = img1URL
        self._imgURL2 = img2URL
        self._votesImage2 = votes2
        self._postID = postID
        self._username = username
        self._caption = caption
        self._profileURL = profileURL
        self._coolCount = coolC
        self._litCount = litC
        self._heartCount = heartC
        self._flowersCount = flowersC
        self._confusedCount = confusedC
        self.isVotingEnabled = isVotingEnabled
        self._userID = userID
        self._status = stat
        self._time = time
        self._rating = rating
        _updateVotesImage1Ref = DataServices.ds.REF_POSTS.child(_postID).child("image1")
        _updateVotesImage2Ref = DataServices.ds.REF_POSTS.child(_postID).child("image2")
        _userDidVoteRef = DataServices.ds.REF_CURRENT_USER
    }
    
    init(img1URL : URL , img2URL : URL , votes1: Float , votes2: Float ,postID : String,isVotingEnabled : Bool , coolC : Int , litC : Int , heartC : Int , flowersC : Int , confusedC : Int) {
        self._votesImage1 = votes1
        self._imgURL1 = img1URL
        self._imgURL2 = img2URL
        self._votesImage2 = votes2
        self._postID = postID
        self.isVotingEnabled = isVotingEnabled
        self._coolCount = coolC
        self._litCount = litC
        self._heartCount = heartC
        self._flowersCount = flowersC
        self._confusedCount = confusedC
        _updateVotesImage1Ref = DataServices.ds.REF_POSTS.child(_postID).child("image1")
        _updateVotesImage2Ref = DataServices.ds.REF_POSTS.child(_postID).child("image2")
        _userDidVoteRef = DataServices.ds.REF_CURRENT_USER
    }
   
    func adjustVotes1(){
        User.u.votes = User.u.votes + 1
        User.u.totalVotes = User.u.totalVotes + 1
        if User.u.remainingPosts < 0{
            if User.u.votes >= (-User.u.remainingPosts * 5) + 5{
                User.u.votes = 0
            }
        }else{
            if User.u.votes == 5{
                User.u.votes = 0
                User.u.remainingPosts = User.u.remainingPosts + 1
            }
        }
//        var votesOfImage : Float = 0.0
//        _updateVotesImage1Ref.observeSingleEvent(of: .value) { [unowned self](snap) in
//            guard snap.exists() else {return}
//            if let v = snap.childSnapshot(forPath: "votes").value{
//                if v is NSNull{
//                    votesOfImage = 0
//                    self._votesImage1 = votesOfImage
//                    self.updateValuesInDBImg1()
//                }else{
//                    votesOfImage = v as! Float
//                    self._votesImage1 = votesOfImage
//                    self.updateValuesInDBImg1()
//                }
//            }else{
//               votesOfImage = 0
//                self._votesImage1 = votesOfImage
//                self.updateValuesInDBImg1()
//            }
//        }
        self._votesImage1 = self._votesImage1 + 1
        _updateVotesImage1Ref.child("votes").setValue(_votesImage1)
        let postID : Dictionary<String,AnyObject> = [_postID : true as AnyObject]
        _userDidVoteRef.child("votedPosts").updateChildValues(postID)
        DataServices.ds.REF_CURRENT_USER.child("votes").setValue(User.u.votes)
        DataServices.ds.REF_CURRENT_USER.child("totalVotes").setValue(User.u.totalVotes)
        DataServices.ds.REF_CURRENT_USER.child("remainingPosts").setValue(User.u.remainingPosts)
    }
    
    func adjustVotes2(){
        User.u.votes = User.u.votes + 1
        User.u.totalVotes = User.u.totalVotes + 1
        if User.u.remainingPosts < 0{
            if User.u.votes >= (-User.u.remainingPosts * 5) + 5{
                User.u.votes = 0
            }
        }else{
            if User.u.votes == 5{
                User.u.votes = 0
                User.u.remainingPosts = User.u.remainingPosts + 1
            }
        }
        
//        var votesOfImage : Float = 0.0
//        _updateVotesImage2Ref.observeSingleEvent(of: .value) { [unowned self](snap) in
//            guard snap.exists() else {return}
//            if let v = snap.childSnapshot(forPath: "votes").value{
//                if v is NSNull{
//                    votesOfImage = 0
//                    self._votesImage2 = votesOfImage
//                    self.updateValuesInDBImg2()
//                }else{
//                    votesOfImage = v as! Float
//                    self._votesImage2 = votesOfImage
//                    self.updateValuesInDBImg2()
//                }
//            }else{
//                votesOfImage = 0
//                self._votesImage2 = votesOfImage
//                self.updateValuesInDBImg2()
//            }
//        }
        self._votesImage2 = self._votesImage2 + 1
        _updateVotesImage2Ref.child("votes").setValue(_votesImage2)
        let postID : Dictionary<String,AnyObject> = [_postID : true as AnyObject]
        _userDidVoteRef.child("votedPosts").updateChildValues(postID)
        DataServices.ds.REF_CURRENT_USER.child("votes").setValue(User.u.votes)
        DataServices.ds.REF_CURRENT_USER.child("totalVotes").setValue(User.u.totalVotes)
        DataServices.ds.REF_CURRENT_USER.child("remainingPosts").setValue(User.u.remainingPosts)
    
    }
    func incrementCool(isIncrement : Bool){
        if isIncrement{
            let userID : Dictionary<String,AnyObject> = [User.u.userID : true as AnyObject]
            self._coolCount = self._coolCount + 1
            DataServices.ds.REF_POSTS.child(_postID).child("cool").setValue(self._coolCount)
            DataServices.ds.REF_POSTS.child(_postID).child("coolUsers").updateChildValues(userID)
            
        }else{
            self._coolCount = self._coolCount - 1
            DataServices.ds.REF_POSTS.child(_postID).child("cool").setValue(self._coolCount)
            let ref = DataServices.ds.REF_POSTS.child(_postID).child("coolUsers").child(User.u.userID)
            ref.removeValue { (err, _) in
                print("TEJ: Error Occured")
            }
        }
        
    }
    func incrementLit(isIncrement : Bool){
        if isIncrement{
            let userID : Dictionary<String,AnyObject> = [User.u.userID : true as AnyObject]
            self._litCount = self._litCount + 1
            DataServices.ds.REF_POSTS.child(_postID).child("lit").setValue(self._litCount)
            DataServices.ds.REF_POSTS.child(_postID).child("litUsers").updateChildValues(userID)
        }else{
            self._litCount = self._litCount - 1
            DataServices.ds.REF_POSTS.child(_postID).child("lit").setValue(self._litCount)
            let ref = DataServices.ds.REF_POSTS.child(_postID).child("litUsers").child(User.u.userID)
            ref.removeValue { (err, _) in
                print("TEJ: Error Occured")
            }
        }
        
    }
    func incrementHeart(isIncrement : Bool){
        if isIncrement{
            let userID : Dictionary<String,AnyObject> = [User.u.userID : true as AnyObject]
            self._heartCount = self._heartCount + 1
            DataServices.ds.REF_POSTS.child(_postID).child("heart").setValue(self._heartCount)
            DataServices.ds.REF_POSTS.child(_postID).child("heartUsers").updateChildValues(userID)
        }else{
            
            self._heartCount = self._heartCount - 1
            DataServices.ds.REF_POSTS.child(_postID).child("heart").setValue(self._heartCount)
            let ref = DataServices.ds.REF_POSTS.child(_postID).child("heartUsers").child(User.u.userID)
            ref.removeValue { (err, _) in
                print("TEJ: Error Occured")
            }
        }
       
    }
    func incrementFlowers(isIncrement : Bool){
        if isIncrement{
            let userID : Dictionary<String,AnyObject> = [User.u.userID : true as AnyObject]
            self._flowersCount = self._flowersCount + 1
            DataServices.ds.REF_POSTS.child(_postID).child("flowers").setValue(self._flowersCount)
            DataServices.ds.REF_POSTS.child(_postID).child("flowersUsers").updateChildValues(userID)
        }else{
            self._flowersCount = self._flowersCount - 1
            DataServices.ds.REF_POSTS.child(_postID).child("flowers").setValue(self._flowersCount)
            let ref = DataServices.ds.REF_POSTS.child(_postID).child("flowersUsers").child(User.u.userID)
            ref.removeValue { (err, _) in
                print("TEJ: Error Occured")
            }
        }
        
    }
    func incrementConfused(isIncrement : Bool){
        if isIncrement{
            let userID : Dictionary<String,AnyObject> = [User.u.userID : true as AnyObject]
            self._confusedCount = self._confusedCount + 1
            DataServices.ds.REF_POSTS.child(_postID).child("confused").setValue(self._confusedCount)
            DataServices.ds.REF_POSTS.child(_postID).child("confusedUsers").updateChildValues(userID)
        }else{
            self._confusedCount = self._confusedCount - 1
            DataServices.ds.REF_POSTS.child(_postID).child("confused").setValue(self._confusedCount)
            let ref = DataServices.ds.REF_POSTS.child(_postID).child("confusedUsers").child(User.u.userID)
            ref.removeValue { (err, _) in
                print("TEJ: Error Occured")
            }
        }
        
    }
    deinit {
        print("DEALLOC POST")
    }
}
