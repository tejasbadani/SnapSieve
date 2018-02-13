//
//  VoteVC.swift
//  SnapSieve
//
//  Created by Tejas Badani on 27/01/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import SwiftKeychainWrapper
import Hero
import Gallery
import Photos
import CoreLocation
import GameplayKit
import Koloda
import FirebaseStorage
import UICircularProgressRing
class VoteVC: UIViewController,GalleryControllerDelegate,CLLocationManagerDelegate {
   

  //: TODO Show the camera button only if the votes are greater than 5 Or show an alert if its less than 5

    @IBOutlet weak var circularRing2: UICircularProgressRingView!
    @IBOutlet weak var circularRing1: UICircularProgressRingView!
    @IBOutlet weak var image2: ShadowImage!
    @IBOutlet weak var image1: ShadowImage!
    @IBOutlet weak var kolodaView1: KolodaView!
    @IBOutlet weak var kolodaView2: KolodaView!
    var locationManager : CLLocationManager!
    var animations: [HeroDefaultAnimationType] = [
        .push(direction: .left),
        .pull(direction: .left),
        .slide(direction: .down),
        .zoomSlide(direction: .left),
        .cover(direction: .up),
        .uncover(direction: .up),
        .pageIn(direction: .left),
        .pageOut(direction: .left),
        .fade,
        .zoom,
        .zoomOut,
        .none
    ]
    var isViewShown : Bool = false
    var imagesE = [UIImage]()
    var convert = PHToImage()
    var currentUserPosts = [String]()
    var allPostsID = [String]()
    var resultPostID = [String]()
    var shuffled = [Any]()
    var posts = [Post]()
    @IBOutlet weak var actionSheetButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var scoreCounter: UILabel!
    @IBOutlet weak var votedLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var toBeSwipedView: UIView!
    @IBOutlet weak var containerView: UIView!
    typealias arrayClosure = (Bool) -> Void
    typealias resultArrayClosure = (Bool) -> Void
    typealias postResultArray = (Bool) -> Void
    typealias kolodaSetup = (Bool) -> Void
    var imageArray1 = [UIImage]()
    var imageArray2 = [UIImage]()
    var isGoingToNextCard : Bool = false
    var didComeFromSwipe : Bool = false
    override func viewDidLayoutSubviews() {
        isViewShown = false
        toggleHidden(hide: true)
        let gestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(animateUIView))
        gestureRecogniser.direction = .up
        self.toBeSwipedView.addGestureRecognizer(gestureRecogniser)
        let xPostion = containerView.frame.origin.x
        let yPostion = containerView.frame.origin.y
        let height = containerView.frame.size.height
        let width = containerView.frame.size.width
        self.containerView.frame = CGRect(x: xPostion, y: yPostion + 85, width: width, height: height)
        self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(animateUIView))
        gestureRecogniser.direction = .up
        self.toBeSwipedView.addGestureRecognizer(gestureRecogniser)
        determineCurrentLocation()
    }
    func determineCurrentLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            print("Executed")
            checkData(completionHandler: { (success) in
                self.getResultPostID(completionHandler: { (check) in
                    self.generateRandomElements(completionHandler: { (check) in
                        self.downloadPostData(completionHandler: { (test) in
                            self.settingUpKoloda()
                        })
                    })
                })
            })
        }
    }
    func checkData(completionHandler: @escaping arrayClosure){
        
        currentUserPosts = []
        allPostsID = []
        print("REF: \(DataServices.ds.REF_CURRENT_USER)")
        let reference = DataServices.ds.REF_CURRENT_USER.child("votedPosts")
        reference.observe(.value) { (snapshot) in
            //Add the postID to an array
            if let dic = snapshot.value as? Dictionary<String,Bool>{
                for (key, _) in dic{
                    self.currentUserPosts.append(key)
                }
                
            }
        }
        DataServices.ds.REF_POSTS.observe(.value) { (snapshot) in
            
            var dwi3 : DispatchWorkItem!
            
            for snap in snapshot.children{
                let userSnap = snap as! DataSnapshot
                let geoFir = GeoFire(firebaseRef: DataServices.ds.REF_POSTS.child(userSnap.key))
                let circle = geoFir.query(at: self.locationManager.location!,withRadius:100)
                dwi3 = DispatchWorkItem {
                    circle.observe(.keyEntered, with: { (str, location) in
                        self.allPostsID.append(str)
                    })
                    sleep(2)
                }
                DispatchQueue.global().async(execute: dwi3)
            }
            let myDq = DispatchQueue(label: "A custom dispatch queue")
            dwi3.notify(queue: myDq) {
                DataServices.ds.REF_CURRENT_USER.child("votedPosts").removeAllObservers()
                DataServices.ds.REF_POSTS.removeAllObservers()
                completionHandler(true)
            }
        }
        
    }
    
    func getResultPostID(completionHandler: @escaping resultArrayClosure){
        resultPostID = []
        print("CURRENT USERS : \(currentUserPosts)")
        resultPostID = allPostsID.filter{!currentUserPosts.contains($0)}
        print("RESULT POST : \(resultPostID)")
        completionHandler(true)
    }
    
    func generateRandomElements(completionHandler : @escaping postResultArray){
        shuffled = GKMersenneTwisterRandomSource.sharedRandom().arrayByShufflingObjects(in: resultPostID)
        completionHandler(true)
    }
    func downloadPostData(completionHandler : @escaping kolodaSetup){
        
        posts = []
        imageArray1 = []
        imageArray2 = []
        var dwi3 : DispatchWorkItem!
        for postID in shuffled{
            dwi3 = DispatchWorkItem{
                DataServices.ds.REF_POSTS.child(postID as! String).observe(.value, with: { (snapshot) in
                    
                    if let postDict = snapshot.value as? Dictionary<String,AnyObject>{
                        var URL1 : String!
                        var URL2 : String!
                        var votes1: Float!
                        var votes2: Float!
                        
                        if let image1 = postDict["image1"] as? Dictionary<String,AnyObject> {
                            if let URL = image1["URL"]{
                                print(URL)
                                URL1 = URL as! String
                            }
                            if let votes = image1["votes"]{
                                print(votes)
                                votes1 = votes as! Float
                            }
                        }
                        if let image2 = postDict["image2"] as? Dictionary<String,AnyObject> {
                            if let URL = image2["URL"]{
                                print(URL)
                                URL2 = URL as! String
                            }
                            if let votes = image2["votes"]{
                                print(votes)
                                votes2 = votes as! Float
                            }
                        }
                        let postObject = Post(img1URL: URL1, img2URL: URL2, votes1: votes1, votes2: votes2 , postID : postID as! String)
                        self.posts.append(postObject)
                        //group.leave()
                    }
                })
                sleep(2)
            }
            DispatchQueue.global().async(execute: dwi3)
            //DataServices.ds.REF_POSTS.child(postID as! String).removeAllObservers()
        }
        
            let myDq = DispatchQueue(label: "A custom dispatch queue")
            dwi3.notify(queue: myDq) {
                for postID in self.shuffled{
                    DataServices.ds.REF_POSTS.child(postID as! String).removeAllObservers()
                }
                
                completionHandler(true)
            }
        
    }
    func settingUpKoloda(){
        let grp = DispatchGroup()
        if posts.count > 5{
            for index in 0...4{
                grp.enter()
                grp.enter()
                print("Executing loop")
                //Download images from the data obtained
                let ref1 = Storage.storage().reference(forURL: posts[index].image1URL)
                ref1.getData(maxSize : 2 * 1024 * 1024, completion : {(data,error) in
                    //grp.enter()
                    if error != nil{
                        print("Unable to download image")
                    }else{
                        
                        print("Image Downloaded from storage")
                        if let imageData = data{
                            if let img = UIImage(data: imageData){
                                self.imageArray1.append(img)
                                grp.leave()
                            }
                        }
                    }
                })
                
              
                let ref2 = Storage.storage().reference(forURL: posts[index].image2URL)
                ref2.getData(maxSize : 2 * 1024 * 1024, completion : {(data,error) in
                    //grp.enter()
                    if error != nil{
                        print("Unable to download image")
                    }else{
                        print("Image Downloaded from storage")
                        if let imageData = data{
                            if let img = UIImage(data: imageData){
                                self.imageArray2.append(img)
                                grp.leave()
                            }
                        }
                    }
                })
            }
        }else{
            for po in posts{
                grp.enter()
                grp.enter()
                
                print("Executing loop 0")
                //Download images from the data obtained
                let ref1 = Storage.storage().reference(forURL: po.image1URL)
                ref1.getData(maxSize : 2 * 1024 * 1024, completion : {(data,error) in
                    //grp.enter()
                    if error != nil{
                        print("Unable to download image")
                    }else{
                        
                        print("Image Downloaded from storage")
                        if let imageData = data{
                            if let img = UIImage(data: imageData){
                                self.imageArray1.append(img)
                                grp.leave()
                            }
                        }
                    }
                })
                
                let ref2 = Storage.storage().reference(forURL: po.image2URL)
                ref2.getData(maxSize : 2 * 1024 * 1024, completion : {(data,error) in
                    //grp.enter()
                    if error != nil{
                        print("Unable to download image")
                    }else{
                        print("Image Downloaded from storage")
                        if let imageData = data{
                            if let img = UIImage(data: imageData){
                                self.imageArray2.append(img)
                                grp.leave()
                            }
                        }
                    }
                })
            }
        }
        
        grp.notify(queue: .main) {
            self.kolodaView1.resetCurrentCardIndex()
            self.kolodaView2.resetCurrentCardIndex()
            self.kolodaView1.dataSource = self
            self.kolodaView1.delegate = self
            self.kolodaView2.dataSource = self
            self.kolodaView2.delegate = self
        }
        
        
    }
  
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
  
    @IBAction func actionSheetClicked(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction = UIAlertAction(title: "Report Image", style: .destructive) { (alert) in
            
        }
        let secondAction = UIAlertAction(title: "Log Out", style: .destructive) { (alert) in
            try! Auth.auth().signOut()
            KeychainWrapper.standard.removeObject(forKey: KEY_UID)
            returnedFromLogin = false
            self.performSegue(withIdentifier: "return", sender: nil)
        }
        let thirdAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
        }
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        alert.addAction(thirdAction)
        present(alert, animated: true, completion: nil)
    }
    func toggleHidden(hide : Bool){
        self.votedLabel.isHidden = hide
        self.scoreCounter.isHidden = hide
        self.cameraButton.isHidden = hide
        self.profileButton.isHidden = hide
        self.actionSheetButton.isHidden = hide
    }
    @objc func animateUIView(gestureRecogniser : UISwipeGestureRecognizer){
        
        if isViewShown == false{
            let xPostion = containerView.frame.origin.x
            let yPostion = containerView.frame.origin.y
            let height = containerView.frame.size.height
            let width = containerView.frame.size.width
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                self.containerView.frame = CGRect(x: xPostion, y: yPostion - 85, width: width, height: height)
                self.arrowImageView.transform = CGAffineTransform.identity
                self.toggleHidden(hide: false)
            }) { (check) in
                self.isViewShown = true
                gestureRecogniser.isEnabled = false
                let gestureRecogniser2 = UISwipeGestureRecognizer(target: self, action: #selector(self.animateUIView2))
                gestureRecogniser2.direction = .down
                self.toBeSwipedView.addGestureRecognizer(gestureRecogniser2)
            }
        }
        
    }
    @objc func animateUIView2(gestureRecogniser : UISwipeGestureRecognizer){
        if isViewShown == true{
            let xPostion = containerView.frame.origin.x
            let yPostion = containerView.frame.origin.y
            let height = containerView.frame.size.height
            let width = containerView.frame.size.width
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                self.containerView.frame = CGRect(x: xPostion, y: yPostion + 85, width: width, height: height)
                self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                self.toggleHidden(hide: true)
            }) { (check) in
                self.isViewShown = false
                gestureRecogniser.isEnabled = false
                let gestureRecogniser2 = UISwipeGestureRecognizer(target: self, action: #selector(self.animateUIView(gestureRecogniser:)))
                gestureRecogniser2.direction = .up
                self.toBeSwipedView.addGestureRecognizer(gestureRecogniser2)
            }
        }
        
    }
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count == 2{
            // imagesE = images
            let asset = images[0].asset
            if let img = convert.conversion(asset){
                imagesE.append(img)
            }
            
            let asset1 = images[1].asset
            if let img = convert.conversion(asset1){
                imagesE.append(img)
            }
            dismiss(animated: true, completion: {
                self.performSegue(withIdentifier: "Camera", sender: nil)
                
            })
            
        }else if images.count == 0 || images.count == 1{
            //Alert View saying you have to choose two images
        }
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        //NVM
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        //NVM
        
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func uploadPhoto(_ sender: Any) {
        
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 2
        let gallery = GalleryController()
        gallery.delegate = self
        present(gallery, animated: true, completion: nil)
        
    }
    @IBAction func viewProfile(_ sender: Any) {
        //:TODO Go to the history of the user view
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Camera" {
            let uploadVC = segue.destination as! UploadImagesVC
            uploadVC.img1 = imagesE.first
            uploadVC.img2 = imagesE.last
        }
    }
}

extension UIImage {
    func crop(to:CGSize) -> UIImage {
        guard let cgimage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        let contextSize: CGSize = contextImage.size
        
        //Set to square
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cropAspect: CGFloat = to.width / to.height
        
        var cropWidth: CGFloat = to.width
        var cropHeight: CGFloat = to.height
        
        if to.width > to.height { //Landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2
        } else if to.width < to.height { //Portrait
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            posX = (contextSize.width - cropWidth) / 2
        } else { //Square
            if contextSize.width >= contextSize.height { //Square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                posX = (contextSize.width - cropWidth) / 2
            }else{ //Square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                posY = (contextSize.height - cropHeight) / 2
            }
        }
        
        let rect: CGRect = CGRect(x : posX, y : posY, width : cropWidth, height : cropHeight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        cropped.draw(in: CGRect(x : 0, y : 0, width : to.width, height : to.height))
        
        return cropped
    }
}

extension VoteVC: KolodaViewDelegate,KolodaViewDataSource{
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        if (koloda == kolodaView1){
            let im = UIImageView(image: imageArray1[index])
            im.contentMode = .scaleAspectFit
            return im
            
        }else{
            let im = UIImageView(image: imageArray2[index])
            im.contentMode = .scaleAspectFit
            return im
        }
        
        
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        print(koloda.countOfCards)
        
        //If both the indexes are 1 then you must continue but only if one of the index is 1 then return
//        if koloda.countOfCards-1 == index {
//            //determineCurrentLocation()
//           return
//
//        }
//        if kolodaView1.countOfCards-1 == index && (kolodaView2.countOfCards-1 != index){
//            return
//        }else if kolodaView2.countOfCards-1 == index && (kolodaView1.countOfCards-1 != index){
//            return
//        }else{
//            //Do nothing
//        }
        if index == koloda.countOfCards-1  {
            
            return
        }
        
        if !(isGoingToNextCard == true){
            
            
            if(koloda == kolodaView1){
                
                
                    posts[index].adjustVotes2()
                    animateViewHidden(kolodaView: kolodaView1)
                    let totalVotes:Float = posts[index].votesImage1 + posts[index].votesImage2
                    animateCircularView(circularView: circularRing2, totalVotes: totalVotes, numeratorVotes: posts[index].votesImage2, viewOne: kolodaView2, viewTwo: kolodaView1)
                
            }else{
                
                    posts[index].adjustVotes1()
                    animateViewHidden(kolodaView: kolodaView2)
                    let totalVotes:Float = posts[index].votesImage1 + posts[index].votesImage2
                    animateCircularView(circularView: circularRing1, totalVotes: totalVotes, numeratorVotes: posts[index].votesImage1, viewOne: kolodaView1, viewTwo: kolodaView2)
               
            }
            
        }else{
            isGoingToNextCard = false
            
        }
      
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        print("Executing DidSelect")
        if (koloda == self.kolodaView1){
            posts[index].adjustVotes1()
            isGoingToNextCard = true
            kolodaView2.swipe(.left)
            animateViewHidden(kolodaView: kolodaView2)
            let totalVotes:Float = posts[index].votesImage1 + posts[index].votesImage2
            animateCircularView(circularView: circularRing1, totalVotes: totalVotes, numeratorVotes: posts[index].votesImage1, viewOne: kolodaView1, viewTwo: kolodaView2)
            if koloda.countOfCards == 0{
                
            }

        }else{
            posts[index].adjustVotes2()
            isGoingToNextCard = true
            kolodaView1.swipe(.right)
            animateViewHidden(kolodaView: kolodaView1)
            let totalVotes:Float = posts[index].votesImage1 + posts[index].votesImage2
            animateCircularView(circularView: circularRing2, totalVotes: totalVotes, numeratorVotes: posts[index].votesImage2, viewOne: kolodaView2, viewTwo: kolodaView1)
            
        }
    }
    func animateCircularView(circularView : UICircularProgressRingView ,totalVotes : Float , numeratorVotes : Float , viewOne : KolodaView , viewTwo: KolodaView){
        circularView.isHidden = false
        print("TOTAL VOTES : \(totalVotes) NUMERATORVOTES : \(numeratorVotes)")
        let  votePercentage :Float = Float((numeratorVotes/totalVotes) * 100)
        print(votePercentage)
        if (votePercentage < 50){
            circularView.innerRingColor = UIColor.red
        }else{
            circularView.innerRingColor = UIColor.green
        }
        circularView.setProgress(value: CGFloat(votePercentage), animationDuration: 3) {
            //Completion Handler
            
            viewOne.swipe(.left)
            self.isGoingToNextCard = true
            circularView.isHidden = true
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseIn, animations: {
                viewTwo.alpha = 1.0
                circularView.value = 0
            }, completion: { (check) in
                
            })
        }
    }
    
   
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        if posts.count > 5{
            return 5
        }else{
        return posts.count
        }
    }
    
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func animateViewHidden(kolodaView : KolodaView){
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseIn, animations: {
            kolodaView.alpha = 0.0
        }, completion: nil)
        
    }
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        if kolodaView1 == koloda{
            determineCurrentLocation()
        }
      
    }
}
