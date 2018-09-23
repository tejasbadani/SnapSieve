//
//  FeedVC1.swift
//  SnapSieve
//
//  Created by Tejas Badani on 21/04/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
import ZAlertView
import SVProgressHUD
import Photos
import Nuke
import Gallery
import GameplayKit
import Alamofire
import AlamofireImage
import SDWebImage

class FeedVC1: UIViewController , UITableViewDelegate , UITableViewDataSource ,showUserProtocol,MessagingDelegate {
    
    let impact = UIImpactFeedbackGenerator(style: .medium)
    var count2 : Int = 0
    var countOfGetDataForPosts : Int = 0
    var convert = PHToImage()
    var locationRadius : Double = 100.00
    var handleSelection  =  HandleSelection()
    let imageCache = NSCache<NSString, UIImage>()
    var votes : String!
    var countOfPosts : Int = 0
    var posts = [Post]()
    var checkArray  = [Int]()
    var currentPosts = [String]()
    var postsArray = [String]()
    var lastKey : String!
    var didFinishRetrievingInfo : Bool = false
    var imagesE = [UIImage]()
    var isViewing : Bool = false
    var disabledUsers = [String]()
    var countOfInitialPosts : Int = 0
    var tempArray  = [String]()
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(FeedVC1.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.black
        
        return refreshControl
    }()
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let dict : Dictionary<String,Bool> = [fcmToken : true]
        // TODO: If necessary send token to application server.
        DataServices.ds.REF_CURRENT_USER.child("notificationToken").setValue(dict)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        Messaging.messaging().delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.addSubview(self.refreshControl)
        tableView.setContentOffset(tableView.contentOffset, animated: false)
        configueSDWebImage()
        //Tutorial Code. Invoke when designed to perfection
//        if KeychainWrapper.standard.string(forKey: TUTORIAL_UID) != nil{
//            //Do nothing - continue with feedVC
//        }else{
//            performSegue(withIdentifier: "Tutorial", sender: nil)
//        }
        
        //If a screenshot was taken in another VC , this Bool handles it
        if NESTED_BACK == true{
            terminationMessageWithProgress()
            NESTED_BACK = false
        }
        setUpZLAlert()
        checkConnection()
        screenShotDetection()
    }
    
    func addTimeToAllPosts(){
        let grp = DispatchGroup()
        DataServices.ds.REF_POSTS.observe(.value) { (snapshot) in
            if snapshot.exists(){
                for obj in snapshot.children{
                    grp.enter()
                    let shot = obj as! DataSnapshot
                    let id = shot.key
                    self.tempArray.append(id)
                    grp.leave()
                }
            }
        }
        grp.notify(queue: .main) {
            //Reverse array
            DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: {
                self.tempArray.reverse()
                print("TEMP ARRAY \(self.tempArray)")
                for obj in self.tempArray{
                    
                    sleep(1)
                    let dateFormatter : DateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let date = Date()
                    let dateString = dateFormatter.string(from: date)
                    print("TIME \(dateString)")
                    let interval = date.timeIntervalSince1970
                    print("INTERVAL \(interval)")
                    DataServices.ds.REF_POSTS.child(obj).updateChildValues(["time":dateString])
                }
            })
           
        }
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        //Reloading the Feed by clearing all the old data
        SVProgressHUD.show()
        startKey = nil
        timeKey = nil
        previousStartKey = nil
        posts = []
        postsArray = []
        checkArray = []
        tableView.reloadData()
        countOfInitialPosts = 0
        handlePagination()
        refreshControl.endRefreshing()
    }
    
    func didShowView(index: Int) {
        //When a row is clicked in the tableView
        performSegue(withIdentifier: "viewUser", sender: index)
    }
    override func viewDidDisappear(_ animated: Bool) {
        //Remove Screenshot Observer
         NotificationCenter.default.removeObserver(self,name: .UIApplicationUserDidTakeScreenshot ,object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    override func viewDidAppear(_ animated: Bool) {
        if (posts.count == 0){
            
            SVProgressHUD.show()
        }
    }
    func configueSDWebImage(){
        //Reduce Memory Load
        SDWebImageDownloader.shared().shouldDecompressImages = false
        SDImageCache.shared().config.shouldDecompressImages = false
        SDImageCache.shared().config.shouldCacheImagesInMemory = false
    }

    func terminationMessageWithProgress(){
        let dialog = ZAlertView(title: "Screenshots are not permitted!", message: "You will no longer see posts from this user. Contact SnapSieve at snapsieve.help@gmail.com for more help.", closeButtonText: "Okay", closeButtonHandler: { [unowned self](alert) in
            alert.dismissAlertView()
            if self.posts.count == 0{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    SVProgressHUD.show()
                })
            }
           
        })
        dialog.show()
        dialog.allowTouchOutsideToDismiss = true
    }
   
    
    func screenShotDetection() {
        //Adding Observer for Screenshots
        NotificationCenter.default.addObserver(self, selector: #selector(didTakeScreenshot), name: .UIApplicationUserDidTakeScreenshot, object: nil)
    }
    @objc func didTakeScreenshot(){
        //Getting the visible tableview cell
        if let index = self.tableView.visibleCells.first?.indexPath?.row , let indexPath = tableView.visibleCells.first?.indexPath{
            let id = posts[index].userID
            let dict = [id : true]
            DataServices.ds.REF_CURRENT_USER.child("DisabledUsers").updateChildValues(dict)
            //Show warning Message
            User.u.terminationMessage()
            //Add to the array
            disabledUsers.append(id)
            posts.remove(at: index)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
    }
    
    func makeAllTheUsersPostFalse(){
        //If you want to modify all the Data in DB. Dont execute until necessary
        DataServices.ds.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                for snap in snapshot.children{
                    let s = snap as! DataSnapshot
                    let id = s.key
                    DataServices.ds.REF_USERS.child(id).child("posts").observeSingleEvent(of: .value, with: { (hot) in
                        if hot.exists(){
                            for eachID in hot.children{
                               let idSnapShot = eachID as! DataSnapshot
                                let postIDDD = idSnapShot.key
                                print("ID HERE 2 \(postIDDD)")
                                let dict = [postIDDD : false]
                                DataServices.ds.REF_USERS.child(id).child("votedPosts").updateChildValues(dict)
                                
                            }
                        }
                    })
                }
            }
        }
    }
    func retrieveUserData(completion : @escaping ()->()){
        //Getting the user data from DB
        
        User.u.userID = KeychainWrapper.standard.string(forKey: KEY_UID)!
        DataServices.ds.REF_CURRENT_USER.observe(.value) { [unowned self ](snapshot) in
            guard snapshot.exists() else{return}
            if let votes = snapshot.childSnapshot(forPath: "votes").value{
                if votes is NSNull{
                    User.u.votes = 0
                }else{
                    User.u.votes = votes as! Int
                }
            }else{
                User.u.votes = 0
            }
            if let totV = snapshot.childSnapshot(forPath: "totalVotes").value{
                if totV is NSNull{
                    User.u.totalVotes = 0
                }else{
                    User.u.totalVotes = totV as! Int
                }
            }
            if let noOfPosts = snapshot.childSnapshot(forPath: "remainingPosts").value{
                if noOfPosts is NSNull{
                    self.didFinishRetrievingInfo = true
                    User.u.remainingPosts = 0
                }else{
                    self.didFinishRetrievingInfo = true
                    User.u.remainingPosts = noOfPosts as! Int
                    self.adjustScore()
                }
            }else{
                self.didFinishRetrievingInfo = true
                User.u.remainingPosts = 0
            }
        }
        checkData {
            completion()
        }
    }
    
    func checkConnection(){
        postsArray = []
        posts = []
        tableView.reloadData()
        disabledUsers = []
        currentPosts = []
        previousStartKey = nil
        startKey = nil
        timeKey = nil
        if Connectivity.isConnectedToInternet(){
            retrieveUserData {
                self.handlePagination()
            }
        }else{
            let dialog = ZAlertView(title: "Oops",
                                    message: "You don't seem to have an active internet connection.",
                                    closeButtonText: "Retry",
                                    closeButtonHandler: { alertView in
                                        self.checkConnection()
                                        alertView.dismissAlertView()
            }
            )
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
        }
    }
    
    //OLD Algorithm
    func beginAlgorithm(){
        
        checkArray = []
        posts = []
        countOfPosts = 0
        self.tableView.reloadData()
        if Connectivity.isConnectedToInternet(){
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
                    if(self.isViewing == false){
                        
                        SVProgressHUD.show()
                        self.isViewing = true
                    }
                }
                
                //Call the methods to everything
                //Get the posts according to location
           
//                self.getPostWithoutLocation(completion:{
//                    //TODO: Executing Very Early
//
//                    if self.countOfPosts == 0 {
//                        self.isViewing = false
//                        SVProgressHUD.dismiss()
//
//                        let dialog = ZAlertView(title: "Wow!", message: "Seems like you have voted for all the posts! There seems to be no other posts though! ", isOkButtonLeft: true, okButtonText: "Retry", cancelButtonText: "Cancel", okButtonHandler: { (alert ) in
//                            self.beginAlgorithm()
//                            alert.dismissAlertView()
//                        }, cancelButtonHandler: { (alert ) in
//                            alert.dismissAlertView()
//                        })
//                        dialog.allowTouchOutsideToDismiss = true
//                        dialog.show()
//                    }else{
//                        self.isViewing = false
//                        SVProgressHUD.dismiss()
//
//                    }
//                })
            
           // self.handlePagination()
        }else{
            let dialog = ZAlertView(title: "Oops",
                                    message: "You don't seem to have an active internet connection.",
                                    closeButtonText: "Retry",
                                    closeButtonHandler: { alertView in
                                        self.checkConnection()
                                        alertView.dismissAlertView()
            }
            )
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
        }
        
    }
    
    func checkData(completion : @escaping ()-> ()) {
        
        //Getting all the voted Posts and the Disabled Users to make the comparisions
        if (isViewing == false){
            
            SVProgressHUD.show()
            isViewing = true
        }
        currentPosts = []
        posts = []
        disabledUsers = []
        let reference2 = DataServices.ds.REF_CURRENT_USER.child("DisabledUsers")
        reference2.observeSingleEvent(of: .value) { [unowned self](snapshot) in
            if let dict = snapshot.value as? Dictionary<String,Bool>{
                for(key,_) in dict{
                    self.disabledUsers.append(key)
                }
            }
        }
        let reference = DataServices.ds.REF_CURRENT_USER.child("votedPosts")
        reference.observeSingleEvent(of : .value) {[unowned self](snapshot) in
            if let dict = snapshot.value as? Dictionary<String,Bool>{
                for(key,_) in dict{
                    self.currentPosts.append(key)
                }
                
            }
            completion()
        }
        
    }
    
    //New algorithm using Pagination.
    var startKey : String!
    var timeKey : String!
    var previousStartKey : String!
    func handlePagination(){
        let ref = DataServices.ds.REF_POSTS.queryOrdered(byChild: "time")
        if timeKey == nil{
            ref.queryLimited(toFirst: 8).observeSingleEvent(of: .value) { [unowned self](snapshot) in
                if snapshot.exists(){
                    guard let children = snapshot.children.allObjects.last as? DataSnapshot else {return}
                    let timeData = children.value as! [String : Any]
                    print("Time value \(timeData)")
                    for snap in snapshot.children{
                        let userSnap = snap as! DataSnapshot
                        let id = userSnap.key
                        //let data = userSnap.value as! [String : Any]
                        if !(self.currentPosts.contains(id)) && !(self.postsArray.contains(id)){
                            print("ID INSIDE::: \(id)")
                            self.postsArray.append(id)
                            self.countOfInitialPosts += 1
                            self.getDataForPost(postID: id)
                        }
                        
                    }
                    if self.countOfInitialPosts < 8{
                        if let time = timeData["time"] as? String{
                            self.timeKey = time
                        }
                        //self.startKey = children.key
                        self.handlePagination()
                    }else{
                        //self.startKey = children.key
                        if let time = timeData["time"] as? String{
                            self.timeKey = time
                        }
                    }
                }
            }
        }else{
            previousStartKey = self.timeKey
            ref.queryStarting(atValue: self.timeKey).queryLimited(toFirst: 8).observeSingleEvent(of: .value) {[unowned self] (snapshot) in
                guard let children = snapshot.children.allObjects.last as? DataSnapshot else {return}
                let timeData = children.value as! [String : Any]
                for snap in snapshot.children{
                    let userSnap = snap as! DataSnapshot
                    let id = userSnap.key
                    if !(self.currentPosts.contains(id)) && !(id == self.timeKey) && !(self.postsArray.contains(id)){
                        print("ID INSIDE::: \(id)")
                        self.postsArray.append(id)
                        self.countOfInitialPosts += 1
                        self.countOfPosts = self.countOfPosts + 1
                        self.getDataForPost(postID: id)
                    }
                    
                }
                //self.startKey = children.key
                if let time = timeData["time"] as? String{
                    self.timeKey = time
                }
                if self.previousStartKey == self.timeKey{
                    //TODO: Reached the end of the number of posts
                    self.spinner.isHidden = true
                    if self.postsArray.count == 0{
                        //Indicate that the posts have been voted
                        let dialog = ZAlertView(title: "Wow",
                                                message: "You seem to have voted for all the posts!",
                                                closeButtonText: "Awesome",
                                                closeButtonHandler: { alertView in
                                                    alertView.dismissAlertView()
                        }
                        )
                        dialog.allowTouchOutsideToDismiss = true
                        dialog.show()
                    }
                    return
                }
                if self.countOfInitialPosts < 8{
                    self.handlePagination()
                }
            }
        }
    }
    //Old Algorithm
//    func getPostWithoutLocation(completion : @escaping ()->()){
//
//            let grp = DispatchGroup()
//
//            DataServices.ds.REF_POSTS.observe(.value) { [unowned self] (snapshot) in
//
//                if snapshot.exists(){
//
//                    for snap in snapshot.children{
//                        grp.enter()
//                        let userSnap = snap as! DataSnapshot
//
//                        let id = userSnap.key
//                        //print("ID IN Initial DATA \(id)")
//                        if !(self.currentPosts.contains(id)){
//
//                            self.postsArray.append(id)
//                            self.countOfPosts = self.countOfPosts + 1
//                            self.getDataForPost(postID: id, completionHere: {
//                                self.countOfGetDataForPosts  = self.countOfGetDataForPosts + 1
//                                grp.leave()
//                            })
//
//                        }else{
//                            grp.leave()
//                        }
//
//                    }
//
//                    grp.notify(queue: .main, execute: {
//                        completion()
//                    })
//
//                }else{
//                    completion()
//                }
//
//            }
//
//    }
    
    //Get Data for each Post
    func getDataForPost(postID : String){
        
        DataServices.ds.REF_POSTS.child(postID).observeSingleEvent(of: .value) { [unowned self ](snapshot) in
            if let postDict = snapshot.value as? Dictionary<String,AnyObject>{
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
                if  let isVoteEnable = postDict["isVotingEnabled"] as? Bool {
                    isVoteEnabled = isVoteEnable
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
                
                if (!self.disabledUsers.contains(userID) && self.postsArray.contains(postID) && isVoteEnabled == true ){
                    self.convertStringToURl(url1: URL1, url2: URL2,id: userID, completionHere: { [unowned self] (url1, url2 , profileURL , rating,postCount,voteCount) in
                        if let url1_1 = url1 , let url2_2 = url2, let url3 = profileURL{
                            let status = Status()
                            let statusString = status.calculateStatus(rating: rating, posts: postCount, votes: voteCount)
                            let postObject = Post(img1URL: url1_1, img2URL: url2_2, votes1: votes1, votes2: votes2 , postID : postID , username : userNameFinal,caption: caption,profileURL : url3 , coolC : coolCount , litC : litCount , heartC : heartCount , flowersC : flowersCount ,confusedC : confusedCount , userID : userID , isVotingEnabled : isVoteEnabled , stat : statusString,time : time,rating: rating)
                            self.posts.append(postObject)
                            
                            SVProgressHUD.dismiss()
                            self.isViewing = false
                            self.tableView.beginUpdates()
                            self.tableView.insertRows(at: [IndexPath(row: self.posts.count-1, section: 0)], with: UITableViewRowAnimation.fade)
                            self.tableView.endUpdates()
                        }
                        
                    })
                }
            }
        }
        
        
    }
    func convertStringToURl(url1 : String , url2: String,id: String,completionHere: @escaping (_ url1 : URL? , _ url2 : URL? , _ profileURL : String? , _ rating : Float , _ posts : Float ,_ votes : Float)->()){
        let reference1 = Storage.storage().reference(forURL: url1)
        reference1.downloadURL(completion: {  (url, err) in
            if err == nil{
                
                if let url1 = url {
                    
                    let reference2 = Storage.storage().reference(forURL: url2)
                    reference2.downloadURL(completion: {(url_2, err) in
                        if err == nil{
                            
                            if let url2 = url_2 {
                                
                                DataServices.ds.REF_USERS.child(id).observeSingleEvent(of: .value, with: {  ( snap) in
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
                                completionHere(nil,nil,nil,0,0,0)
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
    
    func setUpZLAlert(){
        ZAlertView.positiveColor            = UIColor.color("#669999")
        ZAlertView.negativeColor            = UIColor.color("#CC3333")
        ZAlertView.blurredBackground        = false
        ZAlertView.showAnimation            = .fadeIn
        ZAlertView.hideAnimation            = .fadeOut
        //ZAlertView.initialSpringVelocity    = 0.9
        ZAlertView.duration                 = 0.2
        ZAlertView.textFieldTextColor       = UIColor.brown
        ZAlertView.textFieldBackgroundColor = UIColor.color("#EFEFEF")
        ZAlertView.textFieldBorderColor     = UIColor.color("#669999")
    }
    func adjustScore(){
        //Primarily for Score Counter
        //TODO:Add to cummulative score too
        if User.u.remainingPosts < 0{
            votes = "\(User.u.votes!)/\((-User.u.remainingPosts * 5) + 5)"
        }else {
            votes = "\(User.u.votes!)/5"
        }
    }
    
    @objc func tappedImage1(sender : UITapGestureRecognizer){
        
        let tapLocation = sender.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: tapLocation)
        checkArray.append((indexPath?.row)!)
        let currentPost = posts[(indexPath?.row)!]
        let currentCell = self.tableView.cellForRow(at: indexPath!) as! FeedVCCell
        currentPost.adjustVotes1()
        handleSelection.animateCircularView1(totalVotes: currentPost.votesImage1 + currentPost.votesImage2, numeratorVotes: currentPost.votesImage1, circularView: currentCell.progressRing1, imageView: currentCell.imageView1)
        handleSelection.animateCircularView1(totalVotes: currentPost.votesImage1 + currentPost.votesImage2, numeratorVotes: currentPost.votesImage2, circularView: currentCell.progressRing2, imageView: currentCell.imageView2)
        handleSelection.voteCheck()
        currentCell.imageView1.isUserInteractionEnabled = false
        currentCell.imageView2.isUserInteractionEnabled = false
        adjustScore()
        currentPosts.append(currentPost.postID)
        
    }
    
    @objc func tappedImage2(sender : UITapGestureRecognizer){
        let tapLocation = sender.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: tapLocation)
        checkArray.append((indexPath?.row)!)
        let currentPost = posts[(indexPath?.row)!]
        let currentCell = self.tableView.cellForRow(at: indexPath!) as! FeedVCCell
        currentPost.adjustVotes2()
        handleSelection.animateCircularView1(totalVotes: currentPost.votesImage1 + currentPost.votesImage2, numeratorVotes: currentPost.votesImage2, circularView: currentCell.progressRing2, imageView: currentCell.imageView2)
        handleSelection.animateCircularView1(totalVotes: currentPost.votesImage1 + currentPost.votesImage2, numeratorVotes: currentPost.votesImage1, circularView: currentCell.progressRing1, imageView: currentCell.imageView1)
        handleSelection.voteCheck()
        currentCell.imageView1.isUserInteractionEnabled = false
        currentCell.imageView2.isUserInteractionEnabled = false
        adjustScore()
        currentPosts.append(currentPost.postID)
        
    }
    @IBAction func settingsPressed(_ sender: Any) {
        impact.impactOccurred()
        actionSheetShowLogout()
    }
    @IBAction func cameraPressed(_ sender: Any) {
        impact.impactOccurred()
        uploadImage()
    }
    @IBAction func profilePressed(_ sender: Any) {
        impact.impactOccurred()
        self.performSegue(withIdentifier: "ProfileVC1", sender: nil)
    }
    @IBAction func votePressed(_ sender: Any) {
        impact.impactOccurred()
        showPopUp()
    }
    
    func showPopUp(){
        let popVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Pop") as! PopUpViewController
        self.addChildViewController(popVC)
        popVC.view.frame = self.view.frame
        self.view.addSubview(popVC.view)
        popVC.didMove(toParentViewController: self)
    }
    @objc func extraOptionsTapped(sender : UITapGestureRecognizer){
        impact.impactOccurred()
        let tapLocation = sender.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: tapLocation)
        actionSheetShow(index: (indexPath?.row)!)
    }
    
    func actionSheetShowLogout(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let firstAction = UIAlertAction(title: "Log Out", style: .destructive) { (alert) in
            try! Auth.auth().signOut()
            //SVProgressHUD.dismiss()
            KeychainWrapper.standard.removeObject(forKey: KEY_UID)
            if let _ = KeychainWrapper.standard.string(forKey: TUTORIAL_UID){
                KeychainWrapper.standard.removeObject(forKey: TUTORIAL_UID)
            }
            if let _ = KeychainWrapper.standard.string(forKey: STATUS_KEY){
                KeychainWrapper.standard.removeObject(forKey: STATUS_KEY)
            }
            
            returnedFromLogin = false
            self.performSegue(withIdentifier: "return1", sender: nil)
        }
        let secondAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
        }
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        present(alert, animated: true, completion: nil)
        
    }
    func actionSheetShow(index : Int){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction = UIAlertAction(title: "Report Post", style: .destructive) { (alert) in
            
            let dialog = ZAlertView(title: "Report Post",
                                    message: "Are you sure you want to report the post?",
                                    isOkButtonLeft: true,
                                    okButtonText: "Yes",
                                    cancelButtonText: "No",
                                    okButtonHandler: { (alertView) -> () in
                                        //Handle the report action
                                        let dict = [User.u.userID: true]
                                        let dict1 = [self.posts[index].postID : false]
                                        DataServices.ds.REF_REPORTS.child(self.posts[index].postID).updateChildValues(dict)
                                        DataServices.ds.REF_CURRENT_USER.child("reportedPosts").updateChildValues(dict1)
                                        DataServices.ds.REF_CURRENT_USER.child("votedPosts").updateChildValues(dict1)
                                        alertView.dismissAlertView()
                                        
                                        let dialog2 = ZAlertView(title: "Success",
                                                                 message: "The Post has been reported successfully. Thank you for your help to maintain harmony in SnapSieve.",
                                                                 closeButtonText: "Okay",
                                                                 closeButtonHandler: { alertView in
                                                                    self.currentPosts.append(self.posts[index].postID)
                                                                    let indexPath  = IndexPath(row: index , section : 0)
                                                                    self.posts.remove(at: index)
                                                                    self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                                                                    alertView.dismissAlertView()
                                        }
                                        )
                                        dialog2.allowTouchOutsideToDismiss = false
                                        dialog2.show()
                                        
            },
                                    cancelButtonHandler: { (alertView) -> () in
                                        alertView.dismissAlertView()
            }
            )
            dialog.show()
            dialog.allowTouchOutsideToDismiss = true
            
            
        }
        let secondAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
        }
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? FeedVCCell{
            cell.delegate = self
            let currentPost = posts[indexPath.row]
            cell.imageView2.image = nil
            cell.imageView1.image = nil
            if checkArray.contains(indexPath.row){
                cell.configureCell(post: currentPost)
                handleSelection.animateCircularView1(totalVotes: currentPost.votesImage1 + currentPost.votesImage2, numeratorVotes: currentPost.votesImage1, circularView: cell.progressRing1, imageView: cell.imageView1)
                handleSelection.animateCircularView1(totalVotes: currentPost.votesImage1 + currentPost.votesImage2, numeratorVotes: currentPost.votesImage2, circularView: cell.progressRing2, imageView: cell.imageView2)
            }else{
                cell.delegate = self
                cell.imageView1.isUserInteractionEnabled  = true
                cell.imageView2.isUserInteractionEnabled = true
                cell.configureCell(post: currentPost)
                let tapGestureImageView1 = UITapGestureRecognizer(target: self, action: #selector(tappedImage1))
                tapGestureImageView1.numberOfTapsRequired = 2
                cell.imageView1.addGestureRecognizer(tapGestureImageView1)
                
                let tapGestureImageView2 = UITapGestureRecognizer(target: self, action: #selector(tappedImage2))
                tapGestureImageView2.numberOfTapsRequired = 2
                cell.imageView2.addGestureRecognizer(tapGestureImageView2)
            }
            
            let tapGestureImageViewExtra = UITapGestureRecognizer(target: self, action: #selector(extraOptionsTapped(sender:)))
            tapGestureImageViewExtra.numberOfTapsRequired = 1
            cell.extraOptionImageView.addGestureRecognizer(tapGestureImageViewExtra)
            
                let url = URL(string: currentPost.profileURL)
                if let url = url {
                    cell.profileImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "Profile"), options: [.scaleDownLargeImages], completed: nil)
                }
                
                cell.imageView1.sd_setImage(with: currentPost.imgURL1, placeholderImage: #imageLiteral(resourceName: "PlaceholderImage"), options: [.scaleDownLargeImages], completed: nil)
                cell.imageView2.sd_setImage(with: currentPost.imgURL2, placeholderImage: #imageLiteral(resourceName: "PlaceholderImage"), options: [.scaleDownLargeImages], completed: nil)
            
            return cell
        }else{
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? FeedVCCell{
            cell.imageView1.gestureRecognizers?.removeAll()
            cell.imageView2.gestureRecognizers?.removeAll()
            
            cell.extraOptionImageView.gestureRecognizers?.removeAll()
            
        }
    }
    var cellHeights: [IndexPath : CGFloat] = [:]
    //To prevent Cell Jumps
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = cellHeights[indexPath] else { return 800.0 }
        return height
    }
    var spinner = UIActivityIndicatorView()
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            spinner.isHidden = false
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            
            self.tableView.tableFooterView = spinner
            self.tableView.tableFooterView?.isHidden = false
        }
        let lastItem = posts.count - 1
        if indexPath.row == lastItem{
            //More Information
            countOfInitialPosts = 0
            handlePagination()
        }
        
    }
}


