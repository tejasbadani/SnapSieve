//
//  FeedVC.swift
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


class FeedVC: UIViewController , UITableViewDelegate , UITableViewDataSource, CLLocationManagerDelegate  {

    var count1 : Int = 0
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
    var locationManager : CLLocationManager!
    var didFinishRetrievingInfo : Bool = false
    var imagesE = [UIImage]()
    var isViewing : Bool = false
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(FeedVC.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.black
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        self.locationRadius = 100.00
        self.determineCurrentLocation()
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.addSubview(self.refreshControl)
        setUpZLAlert()
        checkConnection()
        
    }
     func downloadImage(url: URL, completion: @escaping (_ image: UIImage?, _ error: Error? ) -> Void) {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage, nil)
        } else {
            Alamofire.request(url).responseImage{ response in
                if let image = response.result.value{
                    self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                    completion(image,nil)
                }else{
                    completion(nil,nil)
                }
            }
        }
    }
    
    func retrieveUserData(completion : @escaping ()->()){
        User.u.userID = KeychainWrapper.standard.string(forKey: KEY_UID)!
        
        DataServices.ds.REF_CURRENT_USER.observe(.value) { (snapshot) in
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
                    User.u.remainingPosts = 1
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
        if Connectivity.isConnectedToInternet(){
            retrieveUserData {
                self.determineCurrentLocation()
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
    
    func determineCurrentLocation(){
        
        checkArray = []
        posts = []
        countOfPosts = 0
        self.tableView.reloadData()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if Connectivity.isConnectedToInternet(){
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
                    
                    if(self.isViewing == false){
                        SVProgressHUD.setBackgroundColor(UIColor.lightGray)
                        SVProgressHUD.show()
                        self.isViewing = true
                    }
                    
                    
                }
                
                //Call the methods to everything
                    //Get the posts according to location
                    self.getPosts(completion: {
                        //TODO: Executing Very Early
                        
                        if self.countOfPosts == 0 && self.locationRadius <= 4000{
                            print("TEJ: Location \(self.locationRadius)")
                            print("TEJ: GETPOSTS COMPlETION")
                            
                            self.locationRadius = self.locationRadius + 50
                            self.locationManager.stopUpdatingLocation()
                            self.determineCurrentLocation()
                        }else{
                            self.locationManager.stopUpdatingLocation()
                            print("TEJ: Location is \(self.locationRadius)")
                            self.isViewing = false
                            SVProgressHUD.dismiss()
                            
                            if self.countOfPosts == 0{
                                let dialog = ZAlertView(title: "Oops",
                                                        message: "Seems like you have voted for almost all posts. Try reloading to get more posts.",
                                                        closeButtonText: "Retry",
                                                        closeButtonHandler: { alertView in
                                                            self.locationRadius = 100.00
                                                            self.determineCurrentLocation()
                                                            alertView.dismissAlertView()
                                }
                                )
                                dialog.allowTouchOutsideToDismiss = false
                                dialog.show()
                            }
                           
                        }
                    })
                
                
            }else{
                
                //:TODO When location is not enabled
                
                self.getPostWithoutLocation {
                    print("TEJ: Completed")
                }
                
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
    
    func checkData(completion : @escaping ()-> ()) {
        
        if (isViewing == false){
            SVProgressHUD.setBackgroundColor(UIColor.lightGray)
            SVProgressHUD.show()
            isViewing = true
        }
        print("TEJ: Check Data")
        currentPosts = []
        posts = []
        let reference = DataServices.ds.REF_CURRENT_USER.child("votedPosts")
        reference.observe(.value) {(snapshot) in
            if let dict = snapshot.value as? Dictionary<String,Bool>{
                print("TEJ: Check Data 2")
                for(key,_) in dict{
                    //print("TEJ: Key is \(key)")
                    self.currentPosts.append(key)
                    //print("TEJ: Current Post \(self.currentPosts)")
                }
                
            }
            reference.removeAllObservers()
            completion()
        }
       
    }
    func getPosts(completion : @escaping ()->()){
        print("TEJ: GetPosts")
        let grp = DispatchGroup()
        //self.posts.removeAll()
        //self.tableView.reloadData()
        DataServices.ds.REF_POSTS.observe(.value) { (snapshot) in
            
            if snapshot.exists(){
                
                for snap in snapshot.children{
                    grp.enter()
                    self.count1 = self.count1 + 1
                    print("TEJ: Count Entry -  \(self.count1)")
                    let userSnap = snap as! DataSnapshot
                    //print("TEJ: User Key : \(userSnap.key)")
                    let geoFir = GeoFire(firebaseRef: DataServices.ds.REF_POSTS.child(userSnap.key))
                    
                    if let location = self.locationManager.location{
                        
                        let circle = geoFir.query(at: location,withRadius:self.locationRadius)
                        
                        circle.observe(.keyEntered, with: { (str, location) in
                            if !(self.currentPosts.contains(str)){
                                
                                
                                
                                //:TODO CHECK HERE
                                //Obtain the data of the postID
                                //Download the images and then using tableview begin updates add the object to the tableView
                                
                                self.countOfPosts = self.countOfPosts + 1
                                self.getDataForPost(postID: str, completionHere: {
                                    
                                    self.countOfGetDataForPosts  = self.countOfGetDataForPosts + 1
                                    print("TEJ: GetDataForPost")
                                    
                                    
                                    //grp.leave()
                                    //self.count2 = self.count2 + 1
                                    //print("TEJ: Count Exit 1 -  \(self.count2)")
                                    
                                })
                                
                                //grp.leave()
                                print("TEJ: Pass \(str)")
                            }else{
                                //grp.leave()
                                
                                print("TEJ: Failed")
                                
                            }
                            
                            
                        })
                       
                        
                            circle.observeReady {
                                grp.leave()
                                self.count2 = self.count2 + 1
                                print("TEJ: Count Exit -  \(self.count2)")
                                print("TEJ: Ready")
                            }
                        
                        
                        
                        
                    }else{
                        grp.leave()
                    }
                  
                    
                    
                }
                
                grp.notify(queue: .main, execute: {
                    print("TEJ: PASS/FAIL RESULT")
                    completion()
                })
                
            }else{
              completion()
            }
            
        }
        
    }
    
    func getPostWithoutLocation(completion : @escaping ()->()){
        
        
        
        print("TEJ: GetPostsWithoutLocation")
        let grp = DispatchGroup()
        //self.posts.removeAll()
        //self.tableView.reloadData()
        DataServices.ds.REF_POSTS.observe(.value) { (snapshot) in
            
            if snapshot.exists(){
                
                for snap in snapshot.children{
                    grp.enter()
                    self.count1 = self.count1 + 1
                    print("TEJ: Count Entry -  \(self.count1)")
                    let userSnap = snap as! DataSnapshot
                    
                    let id = userSnap.key
                    if !(self.currentPosts.contains(id)){
                        
                        self.countOfPosts = self.countOfPosts + 1
                        self.getDataForPost(postID: id, completionHere: {
                            grp.leave()
                            self.countOfGetDataForPosts  = self.countOfGetDataForPosts + 1
                            print("TEJ: GetDataForPost")
                            
                        })
                        
                        print("TEJ: Pass \(id)")
                        
                    }else{
                        grp.leave()
                    }
                    
                }
                
                grp.notify(queue: .main, execute: {
                    print("TEJ: PASS/FAIL RESULT")
                    completion()
                })
                
            }else{
                completion()
            }
            
        }
        
        
        
        
    }
    func getDataForPost(postID : String , completionHere : @escaping ()->()){
        
        print("TEJ: POST ID")
        
        DataServices.ds.REF_POSTS.child(postID).observe(.value) { (snapshot) in
            
            if let postDict = snapshot.value as? Dictionary<String,AnyObject>{
                var URL1 : String!
                var URL2 : String!
                var votes1: Float!
                var votes2: Float!
                var userNameFinal : String!
                var caption : String!
                var userID : String!
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
                self.convertStringToURl(url1: URL1, url2: URL2,id: userID, completionHere: { (url1, url2 , profileURL) in
                    if let url1_1 = url1 , let url2_2 = url2, let url3 = profileURL{
                        
                        DataServices.ds.REF_POSTS.child(postID).removeAllObservers()
                        DataServices.ds.REF_POSTS.removeAllObservers()
                        DataServices.ds.REF_POST_ID.removeAllObservers()
                        DataServices.ds.REF_USERS.removeAllObservers()
                        let postObject = Post(img1URL: url1_1, img2URL: url2_2, votes1: votes1, votes2: votes2 , postID : postID , username : userNameFinal,caption: caption,profileURL : url3)
                        self.posts.append(postObject)
                        SVProgressHUD.dismiss()
                        self.isViewing = false
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: [IndexPath(row: self.posts.count-1, section: 0)], with: .automatic)
                        self.tableView.endUpdates()
                        completionHere()
                    }
                    
                })
               
                //self.tableView.reloadData()
                //group.leave()
            }
        }
        
    }
    func convertStringToURl(url1 : String , url2: String,id: String,completionHere: @escaping (_ url1 : URL? , _ url2 : URL? , _ profileURL : String?)->()){
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
                                        var profileURL : String!
                                        if let url = userDict["profileURL"] as? String{
                                            profileURL = url
                                        }else{
                                            profileURL = ""
                                        }
                                        completionHere(url1,url2,profileURL)
                                    }
                                })
                                
                            }else{
                                completionHere(nil,nil,nil)
                            }
                        }else{
                            completionHere(nil,nil,nil)
                        }
                    })
                    
                }else{
                    completionHere(nil,nil,nil)
                }
            }else{
                completionHere(nil,nil,nil)
                
            }
        })
    }
    
    func setUpZLAlert(){
        ZAlertView.positiveColor            = UIColor.color("#669999")
        ZAlertView.negativeColor            = UIColor.color("#CC3333")
        ZAlertView.blurredBackground        = false
        ZAlertView.showAnimation            = .bounceBottom
        ZAlertView.hideAnimation            = .bounceTop
        ZAlertView.initialSpringVelocity    = 0.9
        ZAlertView.duration                 = 2
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
        actionSheetShowLogout()
    }
    @IBAction func cameraPressed(_ sender: Any) {
        uploadImage()
    }
    @IBAction func profilePressed(_ sender: Any) {
        self.performSegue(withIdentifier: "ProfileVC1", sender: nil)
    }
    @IBAction func votePressed(_ sender: Any) {
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
                                            let dict = [self.posts[index].postID : true]
                                            DataServices.ds.REF_REPORTS.updateChildValues(dict)
                                            DataServices.ds.REF_CURRENT_USER.child("votedPosts").updateChildValues(dict)
                                            alertView.dismissAlertView()
                                            
                                            let dialog2 = ZAlertView(title: "Success",
                                                                     message: "The Post has been reported successfully. Thank you for your help to maintain harmony in SnapSieve.",
                                                                     closeButtonText: "Okay",
                                                                     closeButtonHandler: { alertView in
                                                                        self.currentPosts.append(self.posts[index].postID)
                                                                        self.posts.remove(at: index)
                                                                        self.determineCurrentLocation()
                                                                        //self.tableView.reloadData()
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
            let currentPost = posts[indexPath.row]
            cell.imageView2.image = nil
            cell.imageView1.image = nil
            if checkArray.contains(indexPath.row){
                cell.configureCell(post: currentPost)
                handleSelection.animateCircularView1(totalVotes: currentPost.votesImage1 + currentPost.votesImage2, numeratorVotes: currentPost.votesImage1, circularView: cell.progressRing1, imageView: cell.imageView1)
                handleSelection.animateCircularView1(totalVotes: currentPost.votesImage1 + currentPost.votesImage2, numeratorVotes: currentPost.votesImage2, circularView: cell.progressRing2, imageView: cell.imageView2)
            }else{
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
            
            //Duplicate cells are being created - solve this next
            let url = URL(string: currentPost.profileURL)
            if let url = url {
                Nuke.loadImage(with: url, into: cell.profileImageView)
            }
            
            Nuke.loadImage(with: currentPost.imgURL1, into: cell.imageView1)
            Nuke.loadImage(with: currentPost.imgURL2, into: cell.imageView2)
            
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

}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

