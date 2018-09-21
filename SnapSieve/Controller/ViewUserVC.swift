//
//  ViewUserVC.swift
//  SnapSieve
//
//  Created by Tejas Badani on 16/06/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
import Nuke
import FloatRatingView
import ZAlertView
import Firebase
import SDWebImage
import SVProgressHUD
import SwiftKeychainWrapper
class ViewUserVC: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource , FloatRatingViewDelegate{
    

    let selection = UIImpactFeedbackGenerator(style: .medium)
    @IBOutlet weak var fixedRatingView: FloatRatingView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var profileImageView: RoundedCorners!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var liveRatingValue : Float!
    var userName : String!
    var userID : String!
    var userIDsample : String!
    var profileURL : String!
    var posts = [Post]()
    var didVoteBefore : Bool = false
    var previousRating : Float?
    var totalStars : Float = 0
    var numberOfPeople : Float = 0
    var rating : Float = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            SVProgressHUD.show()
        })
        
        //disableApp()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        loadFromPrevVC()
        retrieveCollectionViewData()
        self.ratingView.delegate = self
        self.ratingView.halfRatings = true
        screenShotDetection()
    }
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self,name: .UIApplicationUserDidTakeScreenshot ,object: nil)
    }
    
    func screenShotDetection() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleScreenshot), name: .UIApplicationUserDidTakeScreenshot, object: nil)
    }
    @objc func handleScreenshot(){
        let dict = [userID : true]
        DataServices.ds.REF_CURRENT_USER.child("DisabledUsers").updateChildValues(dict)
        //Go back to FeedVC and reload the posts
        //RELOAD_BOOL = true
        NESTED_BACK = true
        performSegue(withIdentifier: "UserToFeed", sender: nil)
    }
    
    func retrieveCollectionViewData(){
       // SVProgressHUD.show()
        let group = DispatchGroup()
        DataServices.ds.REF_USERS.child(userID).child("rating").observe(.value) { (snapshot) in
            if let ratingDict = snapshot.value as? Dictionary<String , Any>{

                if let stars = ratingDict["totalStars"] as? Float{
                    self.totalStars = stars
                }else{
                    self.totalStars = 0
                }
                if let noOfPeople = ratingDict["numberOfPeople"] as? Float{
                    self.numberOfPeople = noOfPeople
                }else{
                    self.numberOfPeople = 0
                }
                if let userDict = ratingDict["users"] as? Dictionary<String,Float>{
                    for obj in userDict{
                        if (obj.key == User.u.userID){
                            self.previousRating = obj.value
                            if let prevValue = self.previousRating{
                                self.ratingView.rating = prevValue
                            }

                            self.didVoteBefore = true
                        }
                    }
                }

                self.fixedRatingView.rating = Float(self.totalStars/self.numberOfPeople)

                self.fixedRatingView.isUserInteractionEnabled = false
                
                if self.totalStars == 0 && self.numberOfPeople == 0{
                    self.rating = 0
                    self.fixedRatingView.rating = 0
                }else{
                    self.rating = self.totalStars/self.numberOfPeople
                }

            }
        }
        
        DataServices.ds.REF_USERS.child(userID).observe( .value, with: { (snap) in
            if let userDict  = snap.value as? Dictionary<String,AnyObject>{
                print("EXECUTING ")
                var postCount : Float = 0
                var voteCount : Float = 0
                if let numberOfPosts = userDict["numberOfPosts"] as? Float{
                    postCount = numberOfPosts
                }
                if let totalV = userDict["totalVotes"] as? Float{
                    voteCount = totalV
                }
                
                let status = Status()
                let statusString = status.calculateStatus(rating: self.rating, posts: postCount, votes: voteCount)
                self.statusLabel.text = statusString
               
            }
        })
        
        
        DataServices.ds.REF_USERS.child(userID).child("posts").queryOrderedByKey().observe(.value) { (snapshot) in
            
            if let dic = snapshot.value as? Dictionary<String,Bool>{
                for (key, _) in dic{
                    group.enter()
                    DataServices.ds.REF_POSTS.child(key).observe(.value, with: { (postDataSnapshot) in
                        
                        if let postDict = postDataSnapshot.value as? Dictionary<String,Any>{
                            var URL1 : String!
                            var URL2 : String!
                            var votes1: Float!
                            var votes2: Float!
                            var userNameFinal : String!
                            var caption : String!
                            var userID : String!
                            var coolCount : Int!
                            var litCount : Int!
                            var heartCount : Int!
                            var flowersCount : Int!
                            var confusedCount : Int!
                            var isVoteEnabled : Bool = true
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
                            if let userName = postDict["name"] as? String{
                                userNameFinal = userName
                            }else{
                                userNameFinal = "Unknown"
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
                            
                            self.convertStringToURl(url1: URL1, url2: URL2, id: userID, completionHere: { (url1, url2,rating,postCount,voteCount) in
                                if let url1_1 = url1 , let url2_2 = url2{
                                    
                                    let status = Status()
                                    let statusString = status.calculateStatus(rating: rating, posts: postCount, votes: voteCount)
                                    
                                    let postObject = Post(img1URL: url1_1, img2URL: url2_2, votes1: votes1, votes2: votes2 , postID : key , username : userNameFinal,caption: caption,profileURL : self.profileURL , coolC : coolCount , litC : litCount , heartC : heartCount , flowersC : flowersCount , confusedC : confusedCount , userID : userID , isVotingEnabled : isVoteEnabled,stat : statusString,time : time,rating: rating)
                                    self.posts.append(postObject)
                                    group.leave()
                                    DataServices.ds.REF_POSTS.child(key).removeAllObservers()
                                }else{
                                    group.leave()
                                }
                                
                            })
                            
                        }
                    })
                }
                
            }
            
            group.notify(queue: .main) {
                if self.posts.count <= 0{
                    let dialog = ZAlertView(title: "Oops",
                                            message: "Seems like you havent posted anything yet! Post something to get your results!",
                                            closeButtonText: "Okay",
                                            closeButtonHandler: { alertView in
                                                alertView.dismissAlertView()
                                                self.navigationController?.popViewController(animated: true)
                    }
                    )
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
                    
                }
                DataServices.ds.REF_USERS.child(self.userID).removeAllObservers()
                SVProgressHUD.dismiss()
                self.collectionView.reloadData()
            }
        }
        
    }
    
    
    func convertStringToURl(url1 : String , url2: String , id : String,completionHere: @escaping (_ url1 : URL? , _ url2 : URL? , _ rating : Float , _ posts : Float ,_ votes : Float)->()){
        let reference1 = Storage.storage().reference(forURL: url1)
        reference1.downloadURL(completion: { (url, err) in
            if err == nil{
                
                if let url1 = url {
                    
                    let reference2 = Storage.storage().reference(forURL: url2)
                    reference2.downloadURL(completion: { (url_2, err) in
                        if err == nil{
                            
                            if let url2 = url_2 {
                                
                                
                                DataServices.ds.REF_USERS.child(id).observe(.value, with: { (snap) in
                                    if let userDict  = snap.value as? Dictionary<String,AnyObject>{
                                        var numberofStars : Float = 0
                                        var numberOfUsers : Float = 0
                                        var rating : Float = 0
                                        var postCount : Float = 0
                                        var voteCount : Float = 0
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
                                        
                                        completionHere(url1,url2,rating,postCount,voteCount)
                                    }
                                })
                                
                                //completionHere(url1,url2)
                                
                            }else{
                                completionHere(nil,nil,0,0,0)
                            }
                        }else{
                            completionHere(nil,nil,0,0,0)
                        }
                    })
                    
                }else{
                    completionHere(nil,nil,0,0,0)
                }
            }else{
                completionHere(nil,nil,0,0,0)
                
            }
        })
    }
    
    
    func loadFromPrevVC(){
        
        if let ID  = userIDsample{
            self.userID = ID
        }
        
        if let name = userName{
            self.usernameLabel.text = "\(name)"
        }
        
        if let profile = profileURL{
            if profile == ""{
                //Do nothing
            }else{
                let url = URL(string: profile)
                //Nuke.loadImage(with: url!, into: profileImageView)
                //profileImageView.sd_setImage(with: url!, completed: nil)
                profileImageView.sd_setImage(with: url!, placeholderImage: #imageLiteral(resourceName: "Profile"), options: [.scaleDownLargeImages], completed: nil)
            }
            
        }
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
                cell.configureCell(post: currentPost)
                cell.layer.shouldRasterize = true
                cell.layer.rasterizationScale = UIScreen.main.scale
                //Nuke.loadImage(with: currentPost.imgURL1, into: cell.imageView1)
                //Nuke.loadImage(with: currentPost.imgURL2, into: cell.imageView2)
                cell.imageView1.sd_setImage(with: currentPost.imgURL1, placeholderImage: #imageLiteral(resourceName: "PlaceholderImage"), options: .scaleDownLargeImages, completed: nil)
                cell.imageView2.sd_setImage(with: currentPost.imgURL2, placeholderImage: #imageLiteral(resourceName: "PlaceholderImage"), options: .scaleDownLargeImages, completed: nil)
                return cell
            }else{
                
                return ProfileVCCollectionCell()
            }
            
        }else{
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewPost", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewPost"{
            let viewUserPost = segue.destination as! ViewUserPostVC
            let index = sender as! Int
            viewUserPost.username = usernameLabel.text
            viewUserPost.profileImage = profileImageView.image
            viewUserPost.post = posts[index]
            viewUserPost.status = posts[index].status
            //viewUserPost.id = userID
        }
    }

    
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        liveRatingValue = self.ratingView.rating
        selection.impactOccurred()
        //:TODO Upload to DB the user id under rating-users and the score
        if didVoteBefore == true{
            // Remove old rating and put new rating
            if let oldRating = previousRating{
                totalStars = totalStars - oldRating
                totalStars = totalStars + liveRatingValue
                previousRating = liveRatingValue
                DataServices.ds.REF_USERS.child(userID).child("rating").child("totalStars").setValue(totalStars)
                DataServices.ds.REF_USERS.child(userID).child("rating").child("users").child(User.u.userID).setValue(liveRatingValue)
                
            }
        }else{
            //:Upload new rating
            let dict  = [ "\(User.u.userID!)" : liveRatingValue ]
            DataServices.ds.REF_USERS.child(userID).child("rating").child("users").updateChildValues(dict)
            totalStars = totalStars + liveRatingValue
            numberOfPeople = numberOfPeople + 1
            DataServices.ds.REF_USERS.child(userID).child("rating").child("totalStars").setValue(totalStars)
            DataServices.ds.REF_USERS.child(userID).child("rating").child("numberOfPeople").setValue(numberOfPeople)
            didVoteBefore = true
            previousRating = liveRatingValue
            
        }
        
        
    }
    
   
}




















