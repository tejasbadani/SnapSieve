////
////  FeedVC.swift
////  SnapSieve
////
////  Created by Tejas Badani on 21/04/18.
////  Copyright © 2018 Tejas Badani. All rights reserved.
////
//
//import UIKit
//import SwiftKeychainWrapper
//import Firebase
//import ZAlertView
//import SVProgressHUD
//import Nuke
//import AsyncDisplayKit
//
//class SampleFeedVC: UIViewController , UITableViewDelegate , UITableViewDataSource, CLLocationManagerDelegate,ASTableDataSource,ASTableDelegate,ASBatchFetchingDelegate{
//    func shouldFetchBatch(withRemainingTime remainingTime: TimeInterval, hint: Bool) -> Bool {
//        return true
//    }
//
//
//    var posts = [Post]()
//    var current = [123,456]
//    var currentPosts = [String]()
//    var locationManager : CLLocationManager!
//    var didFinishRetrievingInfo : Bool = false
//    var didObtainFromLocation : Bool = false
//    @IBOutlet weak var tableNode: ASTableNode!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.tableNode.delegate = self
//        self.tableNode.dataSource = self
//        setUpZLAlert()
//        checkConnection()
//        self.view.addSubnode(self.tableNode)
//
//    }
//
//
//    func retrieveUserData(){
//        User.u.userID = KeychainWrapper.standard.string(forKey: KEY_UID)!
//        DataServices.ds.REF_CURRENT_USER.observe(.value) { (snapshot) in
//            guard snapshot.exists() else{return}
//
//            if let votes = snapshot.childSnapshot(forPath: "votes").value{
//                if votes is NSNull{
//                    User.u.votes = 0
//                }else{
//                    User.u.votes = votes as! Int
//                }
//
//            }else{
//                User.u.votes = 0
//            }
//
//            if let noOfPosts = snapshot.childSnapshot(forPath: "remainingPosts").value{
//                if noOfPosts is NSNull{
//                    self.didFinishRetrievingInfo = true
//                    User.u.remainingPosts = 1
//                }else{
//                    self.didFinishRetrievingInfo = true
//                    User.u.remainingPosts = noOfPosts as! Int
//
//                    self.adjustScore()
//                }
//
//            }else{
//                self.didFinishRetrievingInfo = true
//                User.u.remainingPosts = 0
//            }
//
//        }
//    }
//
//    func checkConnection(){
//        if Connectivity.isConnectedToInternet(){
//            retrieveUserData()
//            determineCurrentLocation()
//
//        }else{
//            let dialog = ZAlertView(title: "Oops",
//                                    message: "You don't seem to have an active internet connection.",
//                                    closeButtonText: "Retry",
//                                    closeButtonHandler: { alertView in
//                                        self.checkConnection()
//                                        alertView.dismissAlertView()
//            }
//            )
//            dialog.allowTouchOutsideToDismiss = false
//            dialog.show()
//        }
//    }
//
//    func determineCurrentLocation(){
//        locationManager = CLLocationManager()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()
//
//        if Connectivity.isConnectedToInternet(){
//            if CLLocationManager.locationServicesEnabled() {
//                locationManager.startUpdatingLocation()
//
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
//                    // SVProgressHUD.setBackgroundColor(UIColor.lightGray)
//                    // SVProgressHUD.show()
//
//                }
//
//                //Call the methods to everything
//                checkData {
//                    //Get the posts according to location
//                    print(self.currentPosts)
//                    self.getPosts()
//                }
//
//            }else{
//                let dialog = ZAlertView(title: "Sorry",
//                                        message: "You don't seem to have your location services enabled. Enable location services in settings to use the app.",
//                                        closeButtonText: "Retry",
//                                        closeButtonHandler: { alertView in
//                                            self.determineCurrentLocation()
//                                            alertView.dismissAlertView()
//                }
//                )
//                dialog.allowTouchOutsideToDismiss = false
//                dialog.show()
//
//            }
//        }else{
//            let dialog = ZAlertView(title: "Oops",
//                                    message: "You don't seem to have an active internet connection.",
//                                    closeButtonText: "Retry",
//                                    closeButtonHandler: { alertView in
//                                        self.checkConnection()
//                                        alertView.dismissAlertView()
//            }
//            )
//            dialog.allowTouchOutsideToDismiss = false
//            dialog.show()
//        }
//
//    }
//
//    func checkData(completion : @escaping ()-> ()) {
//        currentPosts = []
//        posts = []
//        let reference = DataServices.ds.REF_CURRENT_USER.child("votedPosts")
//        reference.observe(.value) {(snapshot) in
//            if let dict = snapshot.value as? Dictionary<String,Bool>{
//                for(key,_) in dict{
//                    self.currentPosts.append(key)
//                }
//
//            }
//            //Completion handler true
//            completion()
//        }
//
//    }
//    func getPosts(){
//
//        DataServices.ds.REF_POSTS.observe(.value) { (snapshot) in
//
//            if snapshot.exists(){
//                for snap in snapshot.children{
//                    let userSnap = snap as! DataSnapshot
//                    let geoFir = GeoFire(firebaseRef: DataServices.ds.REF_POSTS.child(userSnap.key))
//                    if let location = self.locationManager.location{
//                        let circle = geoFir.query(at: location,withRadius:4000)
//
//                        self.didObtainFromLocation = true
//                        circle.observe(.keyEntered, with: { (str, location) in
//                            //STR is the postID
//                            if !(self.currentPosts.contains(str)){
//                                //Obtain the data of the postID
//                                //Download the images and then using tableview begin updates add the object to the tableView
//                                self.getDataForPost(postID: str)
//                            }
//                        })
//
//
//                    }else{
//
//                        self.didObtainFromLocation = false
//                    }
//
//
//                }
//            }else{
//
//            }
//
//        }
//
//    }
//
//    func getDataForPost(postID : String){
//        print(postID)
//        DataServices.ds.REF_POSTS.child(postID).observe(.value) { (snapshot) in
//
//            if let postDict = snapshot.value as? Dictionary<String,AnyObject>{
//                var URL1 : String!
//                var URL2 : String!
//                var votes1: Float!
//                var votes2: Float!
//                var userNameFinal : String!
//                var caption : String!
//                if let image1 = postDict["image1"] as? Dictionary<String,AnyObject> {
//                    if let URL = image1["URL"]{
//                        print(URL)
//                        URL1 = URL as! String
//                    }else{
//                        URL1 = "gs://snapsieve.appspot.com/post-pics/Error.png"
//                    }
//                    if let votes = image1["votes"]{
//                        print(votes)
//                        votes1 = votes as! Float
//                    }else{
//                        votes1 = 0
//                    }
//                }else{
//                    print("EXECUTED A")
//                    URL1 = "gs://snapsieve.appspot.com/post-pics/Error.png"
//                    votes1 = 0
//                }
//                if let image2 = postDict["image2"] as? Dictionary<String,AnyObject> {
//                    if let URL = image2["URL"]{
//                        print(URL)
//                        URL2 = URL as! String
//                    }else{
//                        URL2 = "gs://snapsieve.appspot.com/post-pics/Error.png"
//                    }
//                    if let votes = image2["votes"]{
//                        print(votes)
//                        votes2 = votes as! Float
//                    }else{
//                        votes2 = 0
//                    }
//                }else{
//                    print("EXECUTED B")
//                    URL2 = "gs://snapsieve.appspot.com/post-pics/Error.png"
//                    votes2 = 0
//                }
//                if let userName = postDict["name"] as? String{
//                    userNameFinal = userName
//                }else{
//                    userNameFinal = "Unknown"
//                }
//                if let cap = postDict["Caption"] as? String{
//                    if cap == ""{
//                        caption = "Just a casual SnapSiever"
//                    }else{
//                        caption = cap
//                    }
//
//                }else{
//                    caption = "Just a casual SnapSiever"
//                }
//
//                let postObject = Post(img1URL: URL1, img2URL: URL2, votes1: votes1, votes2: votes2 , postID : postID , username : userNameFinal,caption : caption)
//                self.posts.append(postObject)
//                //self.tableNode.beginUpdates()
//                self.tableNode.insertRows(at: [IndexPath(row: self.posts.count-1, section: 0)], with: .automatic)
//                //self.tableNode.endUpdates()
//
//                //self.tableView.reloadData()
//                //group.leave()
//            }
//        }
//
//    }
//
//    func setUpZLAlert(){
//        ZAlertView.positiveColor            = UIColor.color("#669999")
//        ZAlertView.negativeColor            = UIColor.color("#CC3333")
//        ZAlertView.blurredBackground        = false
//        ZAlertView.showAnimation            = .bounceBottom
//        ZAlertView.hideAnimation            = .bounceTop
//        ZAlertView.initialSpringVelocity    = 0.9
//        ZAlertView.duration                 = 2
//        ZAlertView.textFieldTextColor       = UIColor.brown
//        ZAlertView.textFieldBackgroundColor = UIColor.color("#EFEFEF")
//        ZAlertView.textFieldBorderColor     = UIColor.color("#669999")
//    }
//    func adjustScore(){
//        if User.u.remainingPosts < 0{
//            //self.scoreCounter.text = "\(User.u.votes!)/\((-User.u.remainingPosts * 5) + 5)"
//        }else {
//            //self.scoreCounter.text = "\(User.u.votes!)/5"
//        }
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return posts.count
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("Executed \(posts[indexPath.row].image1URL)")
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? FeedVCCell{
//            cell.imageView2.image = nil
//            cell.imageView1.image = nil
//            cell.configureCell(post: posts[indexPath.row])
//
//            let reference1 = Storage.storage().reference(forURL: posts[indexPath.row].image1URL)
//            reference1.downloadURL(completion: { (url, err) in
//                if err == nil{
//
//                    //cell.imageView1.sd_setImage(with: url, completed: nil)
//                    if let url = url {
//                        Nuke.loadImage(with: url, into: cell.imageView1)
//                    }
//
//                    //self.imageA1.append(url!)
//                    //self.urlDict1.updateValue(url!, forKey: self.indexCheckData)
//                }
//            })
//
//            let reference2 = Storage.storage().reference(forURL: posts[indexPath.row].image2URL)
//            reference2.downloadURL(completion: { (url, err) in
//                if err == nil{
//
//                    if let url = url{
//                        Nuke.loadImage(with: url, into: cell.imageView2)
//                    }
//
//                    //cell.imageView2.sd_setImage(with: url, completed: nil)
//                    //self.imageA1.append(url!)
//                    //self.urlDict1.updateValue(url!, forKey: self.indexCheckData)
//                }
//            })
//            return cell
//        }else{
//            return UITableViewCell()
//        }
//    }
//
//    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
//        let node = SampleFeedVCCell()
//
//        return node
//    }
//
//    func numberOfSections(in tableNode: ASTableNode) -> Int {
//        return 1
//    }
//    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
//        return posts.count
//    }
//    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
//
//        return true
//    }
//    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
//
//    }
//
//
//}
//
