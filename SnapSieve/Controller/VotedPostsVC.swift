//
//  VotedPostsVC.swift
//  SnapSieve
//
//  Created by Tejas Badani on 24/06/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
import SVProgressHUD
import ZAlertView
import Firebase
import Nuke
import SDWebImage
import SwiftKeychainWrapper
class VotedPostsVC: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource{

    var posts = [Post]()
    var disabledUsers = [String]()
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //disableApp()
        self.collectionView.delegate = self
        self.collectionView.dataSource  = self
        
//        getTheUsersPosts {
//            self.retrieveCollectionViewData()
//        }
        getTheUsersPosts {
            self.retrieveCollectionViewData()
        }
        //retrieveCollectionViewData()
        //screenShotDetection()
    }
  
    func getTheUsersPosts(completion : @escaping ()->()){
        
        let grp = DispatchGroup()
        DataServices.ds.REF_CURRENT_USER.child("DisabledUsers").observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String,Bool>{
                for(key,_) in dict{
                    grp.enter()
                        self.disabledUsers.append(key)
                        grp.leave()

                }
                
            }
            
            grp.notify(queue: .main, execute: {
                completion()
            })
        }
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    func retrieveCollectionViewData(){

        SVProgressHUD.show()
        let group = DispatchGroup()
        DataServices.ds.REF_CURRENT_USER.child("votedPosts").observeSingleEvent(of : .value) { (snapshot) in
            
            if let dic = snapshot.value as? Dictionary<String,Bool>{
                for (key, val) in dic{
                    print("VAL IS \(val)")
                    group.enter()
                    
                    if(val == true){
                        
                        DataServices.ds.REF_POSTS.child(key).observeSingleEvent(of: .value, with: { (postDataSnapshot) in
                            
                            if let postDict = postDataSnapshot.value as? Dictionary<String,Any>{
                                var URL1 : String!
                                var URL2 : String!
                                var userID : String!
                                var votes1: Float!
                                var votes2: Float!
                                var userNameFinal : String!
                                var isVoteEnabled : Bool = true
                                var coolCount : Int!
                                var litCount : Int!
                                var heartCount : Int!
                                var caption : String!
                                var flowersCount : Int!
                                var confusedCount : Int!
                                var time : String!
                                if let t = postDict["time"] as? String{
                                    time = t
                                }else{
                                    time = ""
                                }
                                if let image1 = postDict["image1"] as? Dictionary<String,AnyObject> {
                                    if let URL = image1["URL"]{
                                        URL1 = URL as! String
                                    }else{
                                        URL1 = "gs://snapsieve.appspot.com/post-pics/Error.png"
                                    }
                                    if let votes = image1["votes"]{
                                        votes1 = votes as! Float
                                    }else{
                                        votes1 = 0
                                    }
                                }else{
                                    URL1 = "gs://snapsieve.appspot.com/post-pics/Error.png"
                                    votes1 = 0
                                }
                                if let image2 = postDict["image2"] as? Dictionary<String,AnyObject> {
                                    if let URL = image2["URL"]{
                                        URL2 = URL as! String
                                    }else{
                                        URL2 = "gs://snapsieve.appspot.com/post-pics/Error.png"
                                    }
                                    if let votes = image2["votes"]{
                                        votes2 = votes as! Float
                                    }else{
                                        votes2 = 0
                                    }
                                }else{
                                    URL2 = "gs://snapsieve.appspot.com/post-pics/Error.png"
                                    votes2 = 0
                                }
                                
                                if  let isVoteEnable = postDict["isVotingEnabled"] as? Bool {
                                    isVoteEnabled = isVoteEnable
                                }
                                if let userName = postDict["name"] as? String{
                                    userNameFinal = userName
                                }else{
                                    userNameFinal = "Unknown"
                                }
                                
                                if let coolC = postDict["cool"] as? Int{
                                    coolCount = coolC
                                }else{
                                    coolCount = 0
                                }
                                if let litC = postDict["lit"] as? Int{
                                    litCount = litC
                                    
                                }else{
                                    litCount = 0
                                }
                                if let heartC = postDict["heart"] as? Int{
                                    heartCount = heartC
                                }else{
                                    heartCount = 0
                                }
                                if let flowersC = postDict["flowers"] as? Int{
                                    flowersCount = flowersC
                                }else{
                                    flowersCount = 0
                                }
                                if let confusedC  = postDict["confused"] as? Int{
                                    confusedCount = confusedC
                                }else{
                                    confusedCount = 0
                                }
                                if let cap = postDict["Caption"] as? String{
                                    if cap == ""{
                                        caption = "Just a casual SnapSiever"
                                    }else{
                                        caption = cap
                                    }
                                    
                                }else{
                                    caption = "Just a casual SnapSiever"
                                }
                                
                                if let userD = postDict["user"] as? Dictionary<String,Bool>{
                                    if let id = userD.keys.first{
                                        userID = id
                                    }else{
                                        userID = ""
                                    }
                                }else{
                                    userID = ""
                                }
                                if (!self.disabledUsers.contains(userID)){
                                    self.convertStringToURl(url1: URL1, url2: URL2, id: userID, completionHere: { (url1, url2,url3,rating,postCount,voteCount)  in
                                        if let url1_1 = url1 , let url2_2 = url2 , let url3_3 = url3{
                                            
                                            let status = Status()
                                            let statusString = status.calculateStatus(rating: rating, posts: postCount, votes: voteCount)
                                            
                                            let postObject = Post(img1URL: url1_1, img2URL: url2_2, votes1: votes1, votes2: votes2 , postID : key , username : userNameFinal,caption: caption,profileURL : url3_3 , coolC : coolCount , litC : litCount , heartC : heartCount , flowersC : flowersCount , confusedC : confusedCount , userID : userID , isVotingEnabled : isVoteEnabled , stat : statusString,time : time,rating: rating)
                                            self.posts.append(postObject)
                                            group.leave()
                                            
                                        }else{
                                            group.leave()
                                        }
                                        
                                    })
                                }else{
                                    group.leave()
                                }
                            }else{
                                group.leave()
                            }
                        })
                        
                    }else{
                        group.leave()
                    }
                 
                }
                
            }
            
            group.notify(queue: .main) {
                if self.posts.count == 0{
                    let dialog = ZAlertView(title: "Oops",
                                            message: "Seems like you havent Voted anything yet! Get on the feed and vote some!",
                                            closeButtonText: "Okay",
                                            closeButtonHandler: { alertView in
                                                alertView.dismissAlertView()
                                                self.navigationController?.popViewController(animated: true)
                    }
                    )
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
                    
                }
                SVProgressHUD.dismiss()
                self.collectionView.reloadData()
            }
        }
        
    }
    
    func convertStringToURl(url1 : String , url2: String,id: String,completionHere: @escaping (_ url1 : URL? , _ url2 : URL? , _ profileURL : String? , _ rating : Float , _ posts : Float ,_ votes : Float)->()){
        let reference1 = Storage.storage().reference(forURL: url1)
        reference1.downloadURL(completion: { (url, err) in
            if err == nil{
                
                if let url1 = url {
                    
                    let reference2 = Storage.storage().reference(forURL: url2)
                    reference2.downloadURL(completion: { (url_2, err) in
                        if err == nil{
                            
                            if let url2 = url_2 {
                                
                                DataServices.ds.REF_USERS.child(id).observeSingleEvent(of: .value, with: { (snap) in
                                    if let userDict  = snap.value as? Dictionary<String,AnyObject>{
                                        var profileURL : String!
                                        var numberofStars : Float = 0
                                        var numberOfUsers : Float = 0
                                        var rating : Float = 0
                                        var postCount : Float = 0
                                        var voteCount : Float = 0
                                        if let url = userDict["profileURL"] as? String{
                                            profileURL = url
                                        }else{
                                            profileURL = ""
                                        }
                                        if let rating = userDict["rating"] as? Dictionary<String,Any>{
                                            if let stars = rating["totalStars"] as? Float{
                                                numberofStars = stars
                                            }
                                            if let people = rating["numberOfPeople"] as? Float{
                                                numberOfUsers = people
                                            }
                                        }
                                        if let numberOfPosts = userDict["numberOfPosts"] as? Float{
                                            postCount = numberOfPosts
                                        }
                                        if let totalV = userDict["totalVotes"] as? Float{
                                            voteCount = totalV
                                        }
                                        if numberofStars == 0 && numberOfUsers == 0{
                                            rating = 0
                                        }else{
                                            rating = numberofStars/numberOfUsers
                                        }
                                        
                                        completionHere(url1,url2,profileURL,rating,postCount,voteCount)
                                    }
                                })
                                
                            }else{
                                completionHere(nil,nil,nil, 0,0,0)
                            }
                        }else{
                            completionHere(nil,nil,nil,0,0,0)
                        }
                    })
                    
                }else{
                    completionHere(nil,nil,nil,0,0,0)
                }
            }else{
                completionHere(nil,nil,nil,0,0,0)
                
            }
        })
    }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if posts.count>0{
            let currentPost = posts[indexPath.row]
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ProfileVCCollectionCell{
                cell.layer.shouldRasterize = true
                cell.layer.rasterizationScale = UIScreen.main.scale
                cell.configureCell(post: currentPost)
                //Nuke.loadImage(with: currentPost.imgURL1, into: cell.imageView1)
                cell.imageView1.sd_setImage(with: currentPost.imgURL1, placeholderImage: #imageLiteral(resourceName: "PlaceholderImage"), options: [.scaleDownLargeImages], completed: nil)
                cell.imageView2.sd_setImage(with: currentPost.imgURL2, placeholderImage: #imageLiteral(resourceName: "PlaceholderImage"), options: [.scaleDownLargeImages], completed: nil)
                //cell.imageView1.sd_setImage(with: currentPost.imgURL1, completed: nil)
                //cell.imageView2.sd_setImage(with: currentPost.imgURL2, completed: nil)
                //Nuke.loadImage(with: currentPost.imgURL2, into: cell.imageView2)
                return cell
            }else{
                
                return ProfileVCCollectionCell()
            }
            
        }else{
            return UICollectionViewCell()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Perform Segue
        performSegue(withIdentifier: "viewVotedPost", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewVotedPost"{
            let viewUserPost = segue.destination as! ViewVotedPostVC
            let index = sender as! Int
            viewUserPost.username = posts[index].userName
            //viewUserPost.profileImage = profileImageView.image
            viewUserPost.post = posts[index]
            viewUserPost.status = posts[index].status
        }
    }
    
}
