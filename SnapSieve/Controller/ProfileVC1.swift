//
//  ProfileVC1.swift
//  SnapSieve
//
//  Created by Tejas Badani on 15/06/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import FloatRatingView
import ZAlertView
import Firebase
import SVProgressHUD

class ProfileVC1: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource {

    let impact = UIImpactFeedbackGenerator(style: .medium)
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            SVProgressHUD.show()
        })
        
       // navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(btnTapped))
//        //navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Profile-Vote"), style: .plain, target: self, action: #selector(btnTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Voted Posts", style: .plain, target: self, action: #selector(btnTapped))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        //navigationItem.rightBarButtonItem?.
       // navigationItem.rightBarButtonItem?.width = 64
//        let button = UIButton.init(type: .custom)
//        button.setImage(#imageLiteral(resourceName: "Profile-Vote"), for: .normal)
//        //button.setImage(UIImage.init(named: "yourImageName.png"), for: UIControlState.normal)
//        button.addTarget(self, action:#selector(btnTapped), for:.touchUpInside)
//        button.frame = CGRect.init(x: 0, y: 0, width: 35, height: 35) //CGRectMake(0, 0, 30, 30)
//        let barButton = UIBarButtonItem.init(customView: button)
//        self.navigationItem.rightBarButtonItem = barButton
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        retrieveUserData()
        
    }
    
    @objc func btnTapped(){
        performSegue(withIdentifier: "votedPosts", sender: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
    
        if didDeletePost == true{
            SVProgressHUD.show()
            self.retrieveUserData()
            didDeletePost = false
            
        }
    }
    
    func showPopUp(){
        let popVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Pop1") as! PopVC2
        self.addChildViewController(popVC)
        popVC.view.frame = self.view.frame
        self.view.addSubview(popVC.view)
        popVC.didMove(toParentViewController: self)
    }
    func retrieveUserData(){
        
        self.posts = []
        self.collectionView.reloadData()
        let group = DispatchGroup()
        DataServices.ds.REF_CURRENT_USER.child("name").observe(.value) { (snapshot) in
            if let username = snapshot.value as? String{
                self.userNameLabel.text = username
            }
        }
        DataServices.ds.REF_CURRENT_USER.child("profileURL").observe(.value) { (snapshot) in
            if let stringURL = snapshot.value as? String{
                let url = URL(string: stringURL)
                //Nuke.loadImage(with: url!, into: self.profileImageView)
                //self.profileImageView.sd_setImage(with: url!, completed: nil)
                self.profileImageView.sd_setImage(with: url!, placeholderImage: #imageLiteral(resourceName: "Profile"), completed: nil)
            }
        }
//        DataServices.ds.REF_USERS.child(User.u.userID).child("rating").observe(.value) { (snapshot) in
//            if let ratingDict = snapshot.value as? Dictionary<String , Any>{
//
//                var totalStars : Float!
//                var numberOfPeople : Float!
//                if let stars = ratingDict["totalStars"] as? Float{
//                    totalStars = stars
//                }else{
//                    totalStars = 0
//                }
//                if let noOfPeople = ratingDict["numberOfPeople"] as? Float{
//                    numberOfPeople = noOfPeople
//                }else{
//                    numberOfPeople = 0
//                }
//
//                print("TEJ: Total Stars \(totalStars)")
//                print("TEJ: Number of people \(numberOfPeople)")
//                self.ratingView.rating = Float(totalStars/numberOfPeople)
//                self.ratingView.isUserInteractionEnabled = false
//
//            }
//        }
        
        DataServices.ds.REF_USERS.child(User.u.userID).observeSingleEvent(of : .value, with: { (snap) in
            if let userDict  = snap.value as? Dictionary<String,AnyObject>{
                var profileURL : String!
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
                self.ratingView.rating = rating
                self.ratingView.isUserInteractionEnabled = false
                let status = Status()
                self.statusLabel.text = status.calculateStatus(rating: rating, posts: postCount, votes: voteCount)
                let statusText = self.statusLabel.text
                if let previousStatus = KeychainWrapper.standard.string(forKey: STATUS_KEY){
                    print("TEJ: PREV \(previousStatus) STAT \(statusText)")
                    if previousStatus == statusText {
                        //Ignore
                    }else{
                        print("TEJ: EXECUTED")
                        User.u.currentStatus = statusText
                        User.u.previousStatus = previousStatus
                        self.impact.impactOccurred()
                        self.showPopUp()
                        KeychainWrapper.standard.set(statusText!, forKey: STATUS_KEY)
                    }
                }else{
                    KeychainWrapper.standard.set(statusText!, forKey: STATUS_KEY)
                }
                
            }
        })
        
        
    
        DataServices.ds.REF_CURRENT_USER.child("posts").queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            
            if let dic = snapshot.value as? Dictionary<String,Bool>{
                for (key, _) in dic{
                    group.enter()
                    DataServices.ds.REF_POSTS.child(key).observeSingleEvent(of: .value, with: { (postDataSnapshot) in
                        
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
                            
                            self.convertStringToURl(url1: URL1, url2: URL2, completionHere: { (url1, url2) in
                                if let url1_1 = url1 , let url2_2 = url2{
                                    let postObject = Post(img1URL: url1_1, img2URL: url2_2, votes1: votes1, votes2: votes2 , postID : key , username : userNameFinal,caption: caption,profileURL : "" , coolC : coolCount , litC : litCount , heartC : heartCount , flowersC : flowersCount , confusedC : confusedCount , userID : userID , isVotingEnabled : isVoteEnabled,time : time)
                                    self.posts.append(postObject)
                                    group.leave()
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
                SVProgressHUD.dismiss()
                self.collectionView.reloadData()
            }
        }
        
    }
    
    
    func convertStringToURl(url1 : String , url2: String,completionHere: @escaping (_ url1 : URL? , _ url2 : URL?)->()){
        let reference1 = Storage.storage().reference(forURL: url1)
        reference1.downloadURL(completion: { (url, err) in
            if err == nil{
                
                if let url1 = url {
                    
                    let reference2 = Storage.storage().reference(forURL: url2)
                    reference2.downloadURL(completion: { (url_2, err) in
                        if err == nil{
                            
                            if let url2 = url_2 {
                                
                                completionHere(url1,url2)
                                
                            }else{
                                completionHere(nil,nil)
                            }
                        }else{
                            completionHere(nil,nil)
                        }
                    })
                    
                }else{
                    completionHere(nil,nil)
                }
            }else{
                completionHere(nil,nil)
                
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
                cell.configureCell(post: currentPost)
                cell.layer.shouldRasterize = true
                cell.layer.rasterizationScale = UIScreen.main.scale
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
        performSegue(withIdentifier: "individualPost", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "individualPost"{
            let viewPost = segue.destination as! ViewPostVC
            let index = sender as! Int
            viewPost.username = userNameLabel.text
            viewPost.status = statusLabel.text
            viewPost.profileImage = profileImageView.image
            viewPost.post = posts[index]
        }
        
    }
    
}



































