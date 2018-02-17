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
    private var _image1URL : String!
    private var _image2URL : String!
    private var _updateVotesImage1Ref : DatabaseReference!
    private var _updateVotesImage2Ref : DatabaseReference!
    private var _userDidVoteRef : DatabaseReference!
    private var _postID : String!
    var votesImage1 : Float{
        return _votesImage1
    }
    var votesImage2 : Float{
        return _votesImage2
    }
    var image1URL : String{
        return _image1URL
    }
    var image2URL : String{
        return _image2URL
    }
    var postID : String{
        return _postID
    }
    init(img1URL : String , img2URL : String , votes1: Float , votes2: Float ,postID : String) {
        self._votesImage1 = votes1
        self._image1URL = img1URL
        self._image2URL = img2URL
        self._votesImage2 = votes2
        self._postID = postID
        _updateVotesImage1Ref = DataServices.ds.REF_POSTS.child(_postID).child("image1")
        _updateVotesImage2Ref = DataServices.ds.REF_POSTS.child(_postID).child("image2")
        _userDidVoteRef = DataServices.ds.REF_CURRENT_USER
    }
   
    func adjustVotes1(){
        User.u.votes = User.u.votes + 1
        if User.u.votes == 5{
            User.u.votes = 0
            User.u.remainingPosts = User.u.remainingPosts + 1
        }
        self._votesImage1 = self._votesImage1 + 1
        _updateVotesImage1Ref.child("votes").setValue(_votesImage1)
        let postID : Dictionary<String,AnyObject> = [_postID : true as AnyObject]
        //_userDidVoteRef.child("votedPosts").updateChildValues(postID)
        DataServices.ds.REF_CURRENT_USER.child("votes").setValue(User.u.votes)
        DataServices.ds.REF_CURRENT_USER.child("remainingPosts").setValue(User.u.remainingPosts)
    }
    func adjustVotes2(){
        User.u.votes = User.u.votes + 1
        if User.u.votes == 5{
            User.u.votes = 0
            User.u.remainingPosts = User.u.remainingPosts + 1
        }
        self._votesImage2 = self._votesImage2 + 1
        _updateVotesImage2Ref.child("votes").setValue(_votesImage2)
        let postID : Dictionary<String,AnyObject> = [_postID : true as AnyObject]
        //_userDidVoteRef.child("votedPosts").updateChildValues(postID)
        DataServices.ds.REF_CURRENT_USER.child("votes").setValue(User.u.votes)
        DataServices.ds.REF_CURRENT_USER.child("remainingPosts").setValue(User.u.remainingPosts)
    }
}
