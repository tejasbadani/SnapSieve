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
import SVProgressHUD
import UIImageCropper
class UploadImagesVC: UIViewController,GalleryControllerDelegate,CLLocationManagerDelegate,UIImageCropperProtocol {
   
    //@IBOutlet weak var circularProgressView: UICircularProgressRingView!
    var locationManager : CLLocationManager!
    var isCameraOne : Bool = false
    var convert = PHToImage()
    let picker = UIImagePickerController()
    let cropper = UIImageCropper(cropRatio: 4/3)
    var originalImage1 : UIImage!
    var originalImage2 : UIImage!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    var img1 : UIImage?
    var img2 : UIImage?
    var checkString : String!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let i = img1{
            let image = i.crop(to: CGSize(width: 343, height: 270))
            image1.image = image
            originalImage1 = i
        }
        if let i = img2{
            let image = i.crop(to: CGSize(width: 343, height: 270))
            image2.image = image
            originalImage2 = i
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
        let group = DispatchGroup()
        SVProgressHUD.setBackgroundColor(UIColor.lightGray)
        SVProgressHUD.show()
        let firebasePost = DataServices.ds.REF_POSTS.childByAutoId()
        if let image = image1.image {
            if let imagedata = UIImageJPEGRepresentation(image, 0.2){
                group.enter()
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
                            group.leave()
                        }
                    }
                    
                }
                let obs = taskUpload.observe(.progress, handler: { (snapshot) in
                    print(snapshot.progress)
                    
                })
            }
        
            
        }
        
        if let image = image2.image{
            if let imagedata = UIImageJPEGRepresentation(image, 0.2){
                group.enter()
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
                            group.leave()
                        }
                    }
                }
            }
        }
        group.notify(queue: .main) {
            SVProgressHUD.dismiss()
            SVProgressHUD.setBackgroundColor(UIColor.white)
            SVProgressHUD.setBorderColor(UIColor.lightGray)
            SVProgressHUD.setBorderWidth(2.0)
            SVProgressHUD.showSuccess(withStatus: "Posted! Check back later to see your result!")
            self.dismiss(animated: true, completion: nil)
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
                    originalImage1 = img
                    image1.image = img
                }
            }else{
                let asset = images[0].asset
                if let img = convert.conversion(asset){
                    originalImage2 = img
                    image2.image = img
                }
            }
        }
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func cropImage1(_ sender: Any) {
        
        cropper.picker = picker
        cropper.delegate = self
        cropper.image = originalImage1
        cropper.cancelButtonText = "Cancel"
        self.present(self.cropper, animated: true, completion: nil)
        checkString = "1"
    }
    @IBAction func cropImage2(_ sender: Any) {
        cropper.picker = picker
        cropper.delegate = self
        cropper.image = originalImage2
        cropper.cancelButtonText = "Cancel"
        self.present(self.cropper, animated: true, completion: nil)
        checkString = "0"
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
    
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
        if checkString == "1"{
            self.image1.image = croppedImage
            checkString = "Random"
        }else if checkString == "0"{
            self.image2.image = croppedImage
            checkString = "Random"
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
