//
//  UploadImagesVC.swift
//  SnapSieve
//
//  Created by Tejas Badani on 31/01/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
import Gallery
import Firebase
import SwiftKeychainWrapper
import UICircularProgressRing
import CoreLocation
class UploadImagesVC: UIViewController,GalleryControllerDelegate,CLLocationManagerDelegate {
    //@IBOutlet weak var circularProgressView: UICircularProgressRingView!
    var locationManager : CLLocationManager!
    var isCameraOne : Bool = false
    var convert = PHToImage()
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    var img1 : UIImage?
    var img2 : UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()

        if let i = img1{
            image1.image = i
        }
        if let i = img2{
            image2.image = i
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        determineCurrentLocation()
    }
    func determineCurrentLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    @IBAction func upload(_ sender: Any) {
        //Converts image to data
        
        let firebasePost = DataServices.ds.REF_POSTS.childByAutoId()
        if let image = img1 {
            if let imagedata = UIImageJPEGRepresentation(image, 0.2){
                
                let imageUID = NSUUID().uuidString
                let metaData = StorageMetadata()
                var taskUpload = StorageUploadTask()
                 taskUpload = DataServices.ds.REF_POST_IMAGES.child(imageUID).putData(imagedata,metadata: metaData){(metaData,error) in
                    
                    if error != nil{
                        print("TEJ: Unable to upload image to firebase storage")
                    }else{
                        
                        print("TEJ: Successfully uploaded image")
                        let downloadURL = metaData?.downloadURL()?.absoluteString
                        
                        if let URL = downloadURL{
                            self.postToFirebase(imageURL: URL,name : "image1",firebasePost)
                        }
                    }
                    
                }
                let obs = taskUpload.observe(.progress, handler: { (snapshot) in
                    print(snapshot.progress)
                    
                })
            }
        
            
        }
        
        if let image = img2{
            if let imagedata = UIImageJPEGRepresentation(image, 0.2){
                
                let imageUID = NSUUID().uuidString
                let metaData = StorageMetadata()
                
                DataServices.ds.REF_POST_IMAGES.child(imageUID).putData(imagedata,metadata: metaData){(metaData,error) in
                    
                    if error != nil{
                        print("TEJ: Unable to upload image to firebase storage")
                    }else{
                        print("TEJ: Successfully uploaded image")
                        
                        let downloadURL = metaData?.downloadURL()?.absoluteString
                        if let URL = downloadURL{
                            self.postToFirebase(imageURL: URL,name : "image2",firebasePost)
                        }
                    }
                }
            }
        }
       
        
        
    }
    
    func postToFirebase(imageURL : String,name : String,_ POST_REF : DatabaseReference){
        
        let image : Dictionary<String,AnyObject> = ["URL":imageURL as AnyObject, "votes":0 as AnyObject]
        let firebasePost2 = POST_REF.child("user")
        let firebasePost = POST_REF.child(name)
        firebasePost.setValue(image)
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let userID : Dictionary<String,AnyObject> = [uid! : true as AnyObject]
        firebasePost2.updateChildValues(userID)
        let id = POST_REF.key
        let postID : Dictionary<String,AnyObject> = [id : true as AnyObject]
        DataServices.ds.REF_CURRENT_USER.child("posts").updateChildValues(postID)
        DataServices.ds.REF_CURRENT_USER.child("votedPosts").updateChildValues(postID)
        DataServices.ds.REF_POST_ID.updateChildValues(postID)
        let geoRef = POST_REF
        let geoFire = GeoFire(firebaseRef: geoRef)
        if let location = locationManager.location{
            geoFire.setLocation(location, forKey: POST_REF.key)
        }
        
    }
    
    @IBAction func cameraOneClicked(_ sender: Any) {
        isCameraOne = true
        showGallery()
    }
    @IBAction func cameraTwoClicked(_ sender: Any) {
        isCameraOne = false
        showGallery()
    }
    @IBAction func cancelClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
    func showGallery(){
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        let gallery = GalleryController()
        gallery.delegate = self
        present(gallery, animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0{
            if isCameraOne == true{
                let asset = images[0].asset
                if let img = convert.conversion(asset){
                    image1.image = img
                }
            }else{
                let asset = images[0].asset
                if let img = convert.conversion(asset){
                    image2.image = img
                }
            }
        }
        dismiss(animated: true, completion: nil)
        
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
    

}
