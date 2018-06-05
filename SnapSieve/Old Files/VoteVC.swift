////
////  VoteVC.swift
////  SnapSieve
////
////  Created by Tejas Badani on 27/01/18.
////  Copyright © 2018 Tejas Badani. All rights reserved.
////
//
//import UIKit
//import FirebaseAuth
//import Firebase
//import SwiftKeychainWrapper
//import Hero
//import Gallery
//import Photos
//import CoreLocation
//import GameplayKit
//import Koloda
//import FirebaseStorage
//import UICircularProgressRing
//import NVActivityIndicatorView
//import SVProgressHUD
//import ZAlertView
//import Crashlytics
//import Floaty
//import BulletinBoard
//class VoteVC: UIViewController,GalleryControllerDelegate,CLLocationManagerDelegate {
//
//    @IBOutlet weak var userNameLabel: UILabel!
//    @IBOutlet weak var circularRing2: UICircularProgressRingView!
//    @IBOutlet weak var circularRing1: UICircularProgressRingView!
//    @IBOutlet weak var image2: ShadowImage!
//    @IBOutlet weak var image1: ShadowImage!
//    @IBOutlet weak var kolodaView1: KolodaView!
//    @IBOutlet weak var kolodaView2: KolodaView!
//    var locationManager : CLLocationManager!
//    var animations: [HeroDefaultAnimationType] = [
//        .push(direction: .left),
//        .pull(direction: .left),
//        .slide(direction: .down),
//        .zoomSlide(direction: .left),
//        .cover(direction: .up),
//        .uncover(direction: .up),
//        .pageIn(direction: .left),
//        .pageOut(direction: .left),
//        .fade,
//        .zoom,
//        .zoomOut,
//        .none
//    ]
//    var isViewShown : Bool = false
//    var imagesE = [UIImage]()
//    var convert = PHToImage()
//    var currentUserPosts = [String]()
//    var allPostsID = [String]()
//    var resultPostID = [String]()
//    var shuffled = [Any]()
//    var posts = [Post]()
//    var imageDictionary1 : Dictionary<Int,UIImage> = [:]
//    var imageDictionary2 : Dictionary<Int,UIImage> = [:]
//    @IBOutlet weak var scoreCounter: UILabel!
//    @IBOutlet weak var votedLabel: UILabel!
//    typealias arrayClosure = (Bool) -> Void
//    typealias resultArrayClosure = (Bool) -> Void
//    typealias postResultArray = (Bool) -> Void
//    typealias kolodaSetup = (Bool) -> Void
//    var imageArray1 = [UIImage]()
//    var imageArray2 = [UIImage]()
//    var isGoingToNextCard : Bool = false
//    var didFinishRetrievingInfo : Bool = false
//    var didObtainFromLocation : Bool = false
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setUpFloaty()
//        if posts.count == 0{
//            image1.image = #imageLiteral(resourceName: "PlaceholderImage")
//            image2.image = #imageLiteral(resourceName: "PlaceholderImage")
//        }
//        setUpZLAlert()
//        checkConnection()
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
//    func setUpFloaty(){
//        let floaty = Floaty()
//        floaty.addItem("Upload Image", icon: #imageLiteral(resourceName: "Camera")) { (item) in
//            self.uploadImage()
//        }
//        floaty.addItem("Profile", icon: #imageLiteral(resourceName: "User")) { (item) in
//            self.performSegue(withIdentifier: "ProfileVC", sender: nil)
//        }
//        floaty.addItem("Options", icon: #imageLiteral(resourceName: "Settings")) { (item) in
//            self.actionSheetShow()
//        }
//        floaty.buttonColor = UIColor(hexString: "#E6E4E4")
//        floaty.hasShadow = true
//        self.view.addSubview(floaty)
//    }
//
//    func checkConnection(){
//        if Connectivity.isConnectedToInternet(){
//            retrieveUserData()
//            determineCurrentLocation()
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
//    func retrieveUserData(){
//       User.u.userID = KeychainWrapper.standard.string(forKey: KEY_UID)!
//       DataServices.ds.REF_CURRENT_USER.observe(.value) { (snapshot) in
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
//                self.kolodaView1.isUserInteractionEnabled = false
//                self.kolodaView2.isUserInteractionEnabled = false
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
//                    SVProgressHUD.setBackgroundColor(UIColor.lightGray)
//                    SVProgressHUD.show()
//
//                }
//
//                checkData(completionHandler: { (success) in
//                    self.getResultPostID(completionHandler: { (check) in
//                        self.generateRandomElements(completionHandler: { (check) in
//                            self.downloadPostData(completionHandler: { (test) in
//                                self.settingUpKoloda()
//                            })
//                        })
//                    })
//                })
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
//    func checkData(completionHandler: @escaping arrayClosure){
//
//        currentUserPosts = []
//        allPostsID = []
//        print("REF: \(DataServices.ds.REF_CURRENT_USER)")
//        let reference = DataServices.ds.REF_CURRENT_USER.child("votedPosts")
//        reference.observe(.value) { (snapshot) in
//            //Add the postID to an array
//            if let dic = snapshot.value as? Dictionary<String,Bool>{
//                for (key, _) in dic{
//                    self.currentUserPosts.append(key)
//                }
//
//            }
//        }
//        DataServices.ds.REF_POSTS.observe(.value) { (snapshot) in
//
//
//                var dwi3 : DispatchWorkItem!
//            if snapshot.exists(){
//                for snap in snapshot.children{
//                    let userSnap = snap as! DataSnapshot
//                    let geoFir = GeoFire(firebaseRef: DataServices.ds.REF_POSTS.child(userSnap.key))
//                    if let location = self.locationManager.location{
//                        let circle = geoFir.query(at: location,withRadius:100)
//                        dwi3 = DispatchWorkItem {
//                            self.didObtainFromLocation = true
//                            circle.observe(.keyEntered, with: { (str, location) in
//                                self.allPostsID.append(str)
//                            })
//                            sleep(2)
//                        }
//                        DispatchQueue.global().async(execute: dwi3)
//                    }else{
//                        dwi3 = DispatchWorkItem {
//                            self.didObtainFromLocation = false
////                            let dialog = ZAlertView(title: "Location services",
////                                                    message: "You don't seem to have location services turned on so we are giving you random posts not based on your location. Enable location to get more targeted posts.",
////                                                    closeButtonText: "Okay",
////                                                    closeButtonHandler: { alertView in
////
////                                                        alertView.dismissAlertView()
////                            }
////                            )
////                            dialog.allowTouchOutsideToDismiss = true
////                            dialog.show()
//                        }
//                        DispatchQueue.global().async(execute: dwi3)
//
//                    }
//
//
//                    }
//
//                let myDq = DispatchQueue(label: "A custom dispatch queue")
//                dwi3.notify(queue: myDq) {
//                    DataServices.ds.REF_CURRENT_USER.child("votedPosts").removeAllObservers()
//                    DataServices.ds.REF_POSTS.removeAllObservers()
//                    completionHandler(true)
//                }
//            }else{
//                completionHandler(true)
//            }
//
//        }
//            }
//
//
//
//    func getResultPostID(completionHandler: @escaping resultArrayClosure){
//        resultPostID = []
//        resultPostID = allPostsID.filter{!currentUserPosts.contains($0)}
//        completionHandler(true)
//    }
//
//    func generateRandomElements(completionHandler : @escaping postResultArray){
//        shuffled = []
//        shuffled = GKMersenneTwisterRandomSource.sharedRandom().arrayByShufflingObjects(in: resultPostID)
//        completionHandler(true)
//    }
//    func downloadPostData(completionHandler : @escaping kolodaSetup){
//
//        posts = []
//        imageArray1 = []
//        imageArray2 = []
//        var dwi3 : DispatchWorkItem!
//        if shuffled.count>0{
//        for postID in shuffled{
//            dwi3 = DispatchWorkItem{
//                DataServices.ds.REF_POSTS.child(postID as! String).observe(.value, with: { (snapshot) in
//
//                    if let postDict = snapshot.value as? Dictionary<String,AnyObject>{
//                        var URL1 : String!
//                        var URL2 : String!
//                        var votes1: Float!
//                        var votes2: Float!
//                        var userNameFinal : String!
//                        var caption : String!
//                        if let image1 = postDict["image1"] as? Dictionary<String,AnyObject> {
//                            if let URL = image1["URL"]{
//                                URL1 = URL as! String
//                            }else{
//                                URL1 = "gs://snapsieve.appspot.com/post-pics/Error.png"
//                            }
//                            if let votes = image1["votes"]{
//                                votes1 = votes as! Float
//                            }else{
//                                votes1 = 0
//                            }
//                        }else{
//                            URL1 = "gs://snapsieve.appspot.com/post-pics/Error.png"
//                            votes1 = 0
//                        }
//                        if let image2 = postDict["image2"] as? Dictionary<String,AnyObject> {
//                            if let URL = image2["URL"]{
//                                URL2 = URL as! String
//                            }else{
//                                URL2 = "gs://snapsieve.appspot.com/post-pics/Error.png"
//                            }
//                            if let votes = image2["votes"]{
//                                votes2 = votes as! Float
//                            }else{
//                                votes2 = 0
//                            }
//                        }else{
//                            URL2 = "gs://snapsieve.appspot.com/post-pics/Error.png"
//                            votes2 = 0
//                        }
//                        if let userName = postDict["name"] as? String{
//                            userNameFinal = userName
//                        }else{
//                            userNameFinal = "Unknown"
//                        }
//                        if let cap = postDict["Caption"] as? String{
//                            if cap == ""{
//                                caption = "Just a casual SnapSiever"
//                            }else{
//                                caption = cap
//                            }
//
//                        }else{
//                            caption = "Just a casual SnapSiever"
//                        }
//                        let postObject = Post(img1URL: URL1, img2URL: URL2, votes1: votes1, votes2: votes2 , postID : postID as! String , username : userNameFinal,caption: caption)
//                        self.posts.append(postObject)
//                    }
//                })
//                sleep(2)
//            }
//            DispatchQueue.global().async(execute: dwi3)
//        }
//        let myDq = DispatchQueue(label: "A custom dispatch queue")
//        dwi3.notify(queue: myDq) {
//            for postID in self.shuffled{
//                DataServices.ds.REF_POSTS.child(postID as! String).removeAllObservers()
//            }
//            completionHandler(true)
//            }
//
//        }else{
//            completionHandler(true)
//        }
//
//
//    }
//    func settingUpKoloda(){
//        let grp = DispatchGroup()
//        if posts.count > 5{
//            for index in 0...4{
//
//                grp.enter()
//                grp.enter()
//                //Download images from the data obtained
//                let ref1 = Storage.storage().reference(forURL: posts[index].image1URL)
//                ref1.getData(maxSize : 2 * 1024 * 1024, completion : {(data,error) in
//                    //grp.enter()
//                    if error != nil{
//                        print("Unable to download image")
//                        self.imageDictionary1.updateValue(#imageLiteral(resourceName: "Error"), forKey: index)
//                        grp.leave()
//                    }else{
//                        print("Image Downloaded from storage")
//                        if let imageData = data{
//                            if let img = UIImage(data: imageData){
//                                self.imageDictionary1.updateValue(img, forKey: index)
//                                grp.leave()
//                            }
//                        }
//                    }
//                })
//
//
//                let ref2 = Storage.storage().reference(forURL: posts[index].image2URL)
//                ref2.getData(maxSize : 2 * 1024 * 1024, completion : {(data,error) in
//                    //grp.enter()
//                    if error != nil{
//                        self.imageDictionary2.updateValue(#imageLiteral(resourceName: "Error"), forKey: index)
//                        print("Unable to download image")
//                        grp.leave()
//                    }else{
//                        print("Image Downloaded from storage")
//                        if let imageData = data{
//                            if let img = UIImage(data: imageData){
//                                self.imageDictionary2.updateValue(img, forKey: index)
//                                grp.leave()
//                            }
//                        }
//                    }
//                })
//            }
//        }else{
//            for (index,po) in posts.enumerated(){
//                grp.enter()
//                grp.enter()
//                //Download images from the data obtained
//                let ref1 = Storage.storage().reference(forURL: po.image1URL)
//                ref1.getData(maxSize : 2 * 1024 * 1024, completion : {(data,error) in
//                    //grp.enter()
//                    if error != nil{
//                        print(po.postID)
//                        self.imageDictionary1.updateValue(#imageLiteral(resourceName: "Error"), forKey: index)
//                        print("Unable to download image")
//                        grp.leave()
//                    }else{
//                        print("Image Downloaded from storage")
//                        if let imageData = data{
//                            if let img = UIImage(data: imageData){
//                                self.imageDictionary1.updateValue(img, forKey: index)
//                                grp.leave()
//                            }
//                        }
//                    }
//                })
//
//                let ref2 = Storage.storage().reference(forURL: po.image2URL)
//                ref2.getData(maxSize : 2 * 1024 * 1024, completion : {(data,error) in
//                    //grp.enter()
//                    if error != nil{
//                        print(po.postID)
//                        print("Unable to download image")
//                        self.imageDictionary2.updateValue(#imageLiteral(resourceName: "Error"), forKey: index)
//                        grp.leave()
//                    }else{
//                        print("Image Downloaded from storage")
//                        if let imageData = data{
//                            if let img = UIImage(data: imageData){
//                                self.imageDictionary2.updateValue(img, forKey: index)
//                                grp.leave()
//                            }
//                        }
//                    }
//                })
//            }
//        }
//
//        grp.notify(queue: .main) {
//            SVProgressHUD.dismiss()
//
//            if (self.posts.count > 0 ){
//
//                self.kolodaView1.countOfVisibleCards = 1
//                self.kolodaView2.countOfVisibleCards = 1
//                self.kolodaView1.isUserInteractionEnabled = true
//                self.kolodaView2.isUserInteractionEnabled = true
//                self.kolodaView1.dataSource = self
//                self.kolodaView1.delegate = self
//                self.kolodaView2.dataSource = self
//                self.kolodaView2.delegate = self
//                self.kolodaView1.resetCurrentCardIndex()
//                self.kolodaView2.resetCurrentCardIndex()
//            }else if self.didObtainFromLocation == false{
//                let dialog = ZAlertView(title: "Oops",
//                                        message: "Seems like we were unable to obtain your location. If you have location services disabled,please do enable it to recieve posts. ",
//                                        closeButtonText: "Retry",
//                                        closeButtonHandler: { alertView in
//                                            self.determineCurrentLocation()
//                                            alertView.dismissAlertView()
//                }
//                )
//                dialog.allowTouchOutsideToDismiss = false
//                dialog.show()
//            }else{
//                let dialog = ZAlertView(title: "Sorry",
//                                        message: "There seem to be no posts near you. Get started by posting your own dilemma. Please try again later.",
//                                        isOkButtonLeft: true,
//                                        okButtonText: "Upload Photo",
//                                        cancelButtonText: "Retry",
//                                        okButtonHandler: { (alertView) -> () in
//
//                                            alertView.dismissAlertView()
//
//                                            Config.tabsToShow = [.imageTab]
//                                            Config.Camera.imageLimit = 2
//                                            let gallery = GalleryController()
//
//                                            gallery.delegate = self
//                                            self.present(gallery, animated: true, completion: nil)
//
//                },
//                                        cancelButtonHandler: { (alertView) -> () in
//
//                                            alertView.dismissAlertView()
//                                            self.determineCurrentLocation()
//                }
//
//                )
//
//                dialog.show()
//                dialog.allowTouchOutsideToDismiss = true
//            }
//
//        }
//
//
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let userLocation:CLLocation = locations[0] as CLLocation
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
//    {
//        print("Error \(error)")
//    }
//
//    @IBAction func reloadData(_ sender: Any) {
//        self.determineCurrentLocation()
//    }
//
//    func actionSheetShow(){
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let firstAction = UIAlertAction(title: "Report Post", style: .destructive) { (alert) in
//
//            if (self.posts.count)>0{
//                let dialog = ZAlertView(title: "Report Post",
//                                        message: "Are you sure you want to report the post?",
//                                        isOkButtonLeft: true,
//                                        okButtonText: "Yes",
//                                        cancelButtonText: "No",
//                                        okButtonHandler: { (alertView) -> () in
//                                            //Handle the report action
//                                            let dict = [self.posts[self.kolodaView1.currentCardIndex].postID : true]
//                                            DataServices.ds.REF_REPORTS.updateChildValues(dict)
//                                            DataServices.ds.REF_CURRENT_USER.child("votedPosts").updateChildValues(dict)
//                                            alertView.dismissAlertView()
//
//
//                                            let dialog2 = ZAlertView(title: "Success",
//                                                                     message: "The Post has been reported successfully. Thank you for your cooperation.",
//                                                                     closeButtonText: "Okay",
//                                                                     closeButtonHandler: { alertView in
//                                                                        alertView.dismissAlertView()
//                                                                        self.determineCurrentLocation()
//
//
//                                            }
//                                            )
//                                            dialog2.allowTouchOutsideToDismiss = false
//                                            dialog2.show()
//
//                },
//                                        cancelButtonHandler: { (alertView) -> () in
//                                            alertView.dismissAlertView()
//                }
//                )
//                dialog.show()
//                dialog.allowTouchOutsideToDismiss = true
//            }else{
//                let dialog = ZAlertView(title: "Oops!",
//                                        message: "There isnt a post you can report! ",
//                                        closeButtonText: "Okay",
//                                        closeButtonHandler: { alertView in
//                                            alertView.dismissAlertView()
//                }
//                )
//                dialog.allowTouchOutsideToDismiss = true
//                dialog.show()
//            }
//
//        }
//        let secondAction = UIAlertAction(title: "Log Out", style: .destructive) { (alert) in
//            try! Auth.auth().signOut()
//            KeychainWrapper.standard.removeObject(forKey: KEY_UID)
//            returnedFromLogin = false
//            self.performSegue(withIdentifier: "return", sender: nil)
//        }
//        let thirdAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
//        }
//        alert.addAction(firstAction)
//        alert.addAction(secondAction)
//        alert.addAction(thirdAction)
//        present(alert, animated: true, completion: nil)
//    }
//
//    func adjustScore(){
//        if User.u.remainingPosts < 0{
//            self.scoreCounter.text = "\(User.u.votes!)/\((-User.u.remainingPosts * 5) + 5)"
//        }else {
//            self.scoreCounter.text = "\(User.u.votes!)/5"
//        }
//    }
//
//    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
//        imagesE = []
//        if images.count == 2{
//            // imagesE = images
//            let asset = images[0].asset
//            if let img = convert.conversion(asset){
//                imagesE.append(img)
//            }
//
//            let asset1 = images[1].asset
//            if let img = convert.conversion(asset1){
//                imagesE.append(img)
//            }
//            dismiss(animated: true, completion: {
//                self.performSegue(withIdentifier: "Camera", sender: nil)
//
//
//            })
//
//        }else if images.count == 0 || images.count == 1{
//            //Alert View saying you have to choose two images
//            let dialog = ZAlertView(title: "Oops",
//                                    message: "Seems like you haven't picked enough photos. Pick two photos!",
//                                    closeButtonText: "Okay",
//                                    closeButtonHandler: { alertView in
//                                        alertView.dismissAlertView()
//            }
//            )
//            dialog.allowTouchOutsideToDismiss = true
//            dialog.show()
//        }
//    }
//
//    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
//        //NVM
//    }
//
//    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
//        //NVM
//
//    }
//
//    func galleryControllerDidCancel(_ controller: GalleryController) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    func uploadImage(){
//        if didFinishRetrievingInfo == true{
//            if (User.u.remainingPosts > 0){
//                Config.tabsToShow = [.imageTab]
//                Config.Camera.imageLimit = 2
//                let gallery = GalleryController()
//                gallery.delegate = self
//                present(gallery, animated: true, completion: nil)
//            }else{
//                //Alert to tell user nope
//                let dialog = ZAlertView(title: "Oops",
//                                        message: "Seems like you haven't voted enough. Vote more to post!",
//                                        closeButtonText: "Okay",
//                                        closeButtonHandler: { alertView in
//                                            alertView.dismissAlertView()
//                }
//                )
//                dialog.allowTouchOutsideToDismiss = true
//                dialog.show()
//            }
//        }else{
//            let dialog = ZAlertView(title: "One moment!",
//                                    message: "Loading your information...",
//                                    closeButtonText: "Okay",
//                                    closeButtonHandler: { alertView in
//                                        alertView.dismissAlertView()
//            }
//            )
//            dialog.allowTouchOutsideToDismiss = true
//            dialog.show()
//        }
//    }
//    @IBAction func uploadPhoto(_ sender: Any) {
//
//
//    }
//
//    @IBAction func viewProfile(_ sender: Any) {
//        //:TODO Go to the history of the user view
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "Camera" {
//            let uploadVC = segue.destination as! UploadImagesVC
//            uploadVC.img1 = imagesE.first
//            uploadVC.img2 = imagesE.last
//        }
//    }
//}
//
//
//
//extension VoteVC: KolodaViewDelegate,KolodaViewDataSource{
//    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
//        self.userNameLabel.text = posts[index].userName
//        if (koloda == kolodaView1){
//            var im: UIImageView!
//            if let _ = imageDictionary1[index] , let _ = imageDictionary2[index]{
//                 im = UIImageView(image: self.imageDictionary1[index])
//                im.contentMode = .scaleAspectFit
//            }
//
//            self.image1.image = #imageLiteral(resourceName: "Empty")
//            return im
//
//        }else{
//            var im: UIImageView!
//            if let _ = imageDictionary1[index] , let _ = imageDictionary2[index]{
//
//                im = UIImageView(image: self.imageDictionary2[index])
//                im.contentMode = .scaleAspectFit
//            }
//            self.image2.image = #imageLiteral(resourceName: "Empty")
//            return im
//        }
//
//
//    }
//
//    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
//        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
//    }
//    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
//
//        if !(isGoingToNextCard == true){
//
//            if(koloda == kolodaView1){
//
//                koloda.alpha = 0
//                    posts[index].adjustVotes2()
//                self.userNameLabel.isHidden = true
//                    animateViewHidden(kolodaView: kolodaView1)
//                    let totalVotes:Float = posts[index].votesImage1 + posts[index].votesImage2
//                    animateCircularView(circularView: circularRing2, totalVotes: totalVotes, numeratorVotes: posts[index].votesImage2, viewOne: kolodaView2, viewTwo: kolodaView1)
//                self.adjustScore()
//
//
//            }else{
//
//                koloda.alpha = 0
//
//                    posts[index].adjustVotes1()
//                self.userNameLabel.isHidden = true
//                    animateViewHidden(kolodaView: kolodaView2)
//                    let totalVotes:Float = posts[index].votesImage1 + posts[index].votesImage2
//                    animateCircularView(circularView: circularRing1, totalVotes: totalVotes, numeratorVotes: posts[index].votesImage1, viewOne: kolodaView1, viewTwo: kolodaView2)
//                //self.scoreCounter.text = "\(User.u.votes!)/5"
//                self.adjustScore()
//
//            }
//
//        }else{
//            isGoingToNextCard = false
//
//        }
//
//    }
//
//    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
//
//        if (koloda == self.kolodaView1){
//            posts[index].adjustVotes1()
//            isGoingToNextCard = true
//            kolodaView2.swipe(.left)
//            self.userNameLabel.isHidden = true
//            animateViewHidden(kolodaView: kolodaView2)
//            let totalVotes:Float = posts[index].votesImage1 + posts[index].votesImage2
//            animateCircularView(circularView: circularRing1, totalVotes: totalVotes, numeratorVotes: posts[index].votesImage1, viewOne: kolodaView1, viewTwo: kolodaView2)
//            //self.scoreCounter.text = "\(User.u.votes!)/5"
//            self.adjustScore()
//
//        }else{
//            posts[index].adjustVotes2()
//            isGoingToNextCard = true
//            kolodaView1.swipe(.right)
//            self.userNameLabel.isHidden = true
//            animateViewHidden(kolodaView: kolodaView1)
//            let totalVotes:Float = posts[index].votesImage1 + posts[index].votesImage2
//            animateCircularView(circularView: circularRing2, totalVotes: totalVotes, numeratorVotes: posts[index].votesImage2, viewOne: kolodaView2, viewTwo: kolodaView1)
//            //self.scoreCounter.text = "\(User.u.votes!)/5"
//            self.adjustScore()
//
//        }
//    }
//    func animateCircularView(circularView : UICircularProgressRingView ,totalVotes : Float , numeratorVotes : Float , viewOne : KolodaView , viewTwo: KolodaView){
//
//
//        circularView.isHidden = false
//        let  votePercentage :Float = Float((numeratorVotes/totalVotes) * 100)
//        if (votePercentage < 50){
//            circularView.innerRingColor = UIColor.red
//        }else{
//            circularView.innerRingColor = UIColor.green
//        }
//        viewOne.alpha = 0.5
//        circularView.setProgress(to: CGFloat(votePercentage), duration: 3) {
//
//            if User.u.votes == 0{
//                let dialog = ZAlertView(title: "Well Done!",
//                                        message: "You now have acccess to one more post! ",
//                                        closeButtonText: "Okay",
//                                        closeButtonHandler: { alertView in
//                                            alertView.dismissAlertView()
//                }
//                )
//                dialog.allowTouchOutsideToDismiss = true
//                dialog.show()
//            }
//            self.isGoingToNextCard = true
//            viewOne.swipe(.left)
//            circularView.isHidden = true
//            //self.userNameLabel.text = ""
//            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseIn, animations: {
//                self.userNameLabel.isHidden = false
//                viewTwo.alpha = 1.0
//                viewOne.alpha = 1.0
//                circularView.value = 0
//            }, completion: { (check) in
//
//            })
//        }
//    }
//
//
//
//    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
//        if posts.count > 5{
//            return 5
//        }else{
//        return posts.count
//        }
//    }
//
//
//    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
//        return .default
//    }
//
//    func animateViewHidden(kolodaView : KolodaView){
//        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
//            kolodaView.alpha = 0.0
//        }, completion: nil)
//
//    }
//    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
//
//        self.userNameLabel.text = ""
//        self.image1.image = #imageLiteral(resourceName: "PlaceholderImage")
//        self.image2.image = #imageLiteral(resourceName: "PlaceholderImage")
//        if kolodaView1 == koloda{
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
//
//                self.determineCurrentLocation()
//            })
//
//        }
//    }
//    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
//        return [.left,.right]
//    }
//}
//extension UIColor {
//    convenience init(hexString: String) {
//        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int = UInt32()
//        Scanner(string: hex).scanHexInt32(&int)
//        let a, r, g, b: UInt32
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (255, 0, 0, 0)
//        }
//        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
//    }
//}
//
