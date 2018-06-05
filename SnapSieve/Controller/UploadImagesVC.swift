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
import ZAlertView
import CropViewController
class UploadImagesVC: UIViewController,GalleryControllerDelegate,CLLocationManagerDelegate,CropViewControllerDelegate,UITextFieldDelegate {
   
    //@IBOutlet weak var circularProgressView: UICircularProgressRingView!
    var locationManager : CLLocationManager!
    var isCameraOne : Bool = false
    var convert = PHToImage()
    
    var originalImage1 : UIImage!
    var originalImage2 : UIImage!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    var img1 : UIImage?
    var img2 : UIImage?
    var checkString : String!
    var textFieldCaption : UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let i = img1{
        
            let image = cropImageToSquare(image: i)
            image1.image = image
            originalImage1 = i
        }
        if let i = img2{
            
            let image = cropImageToSquare(image: i)
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
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    @IBAction func upload(_ sender: Any) {
     
       askForCaption()
        
        
    }
    
    func uploadToFirebaseAfterCaption(caption : String){
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
                        group.leave()
                    }else{
                        
                        print("TEJ: Successfully uploaded image")
                        let downloadURL = metaData?.downloadURL()?.absoluteString
                        
                        if let URL = downloadURL{
                            self.postToFirebase(imageURL: URL,name : "image1",firebasePost)
                            group.leave()
                        }
                    }
                    
                }
                //                let obs = taskUpload.observe(.progress, handler: { (snapshot) in
                //                    print(snapshot.progress)
                //
                //                })
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
                        group.leave()
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
        DataServices.ds.REF_POSTS.child(firebasePost.key).child("Caption").setValue(caption)
        group.notify(queue: .main) {
            SVProgressHUD.dismiss()
            SVProgressHUD.setBackgroundColor(UIColor.white)
            SVProgressHUD.setBorderColor(UIColor.lightGray)
            SVProgressHUD.setBorderWidth(2.0)
            SVProgressHUD.showSuccess(withStatus: "Posted! Check back later to see your result!")
            User.u.remainingPosts = User.u.remainingPosts - 1
            DataServices.ds.REF_CURRENT_USER.child("remainingPosts").setValue(User.u.remainingPosts)
            
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    func postToFirebase(imageURL : String,name : String,_ POST_REF : DatabaseReference){
        
        //Upload the profile image URL to the post / or upload it to the user and get it from there
        let image : Dictionary<String,AnyObject> = ["URL":imageURL as AnyObject, "votes":0 as AnyObject]
        let firebasePost2 = POST_REF.child("user")
        let firebasePost = POST_REF.child(name)
        firebasePost.setValue(image)
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let userID : Dictionary<String,AnyObject> = [uid! : true as AnyObject]
        firebasePost2.updateChildValues(userID)
        let id = POST_REF.key
        let postID : Dictionary<String,AnyObject> = [id : true as AnyObject]
        DataServices.ds.REF_POSTS.child(id).child("name").setValue(DataServices.ds.CURRENT_USER_NAME)
        DataServices.ds.REF_POSTS.child(id).child("isVotingEnabled").setValue(true)
        DataServices.ds.REF_CURRENT_USER.child("posts").updateChildValues(postID)
        DataServices.ds.REF_CURRENT_USER.child("votedPosts").updateChildValues(postID)
        DataServices.ds.REF_POST_ID.updateChildValues(postID)
        let geoRef = POST_REF
        let geoFire = GeoFire(firebaseRef: geoRef)
        if let location = locationManager.location{
            geoFire.setLocation(location, forKey: POST_REF.key)
        }
        
    }
    
    func askForCaption(){
        
     
        let caption = ZAlertView(title: "Caption", message: "Would you like to add a caption for your Post? (We recommend a kickass caption)", isOkButtonLeft: false, okButtonText: "Upload", cancelButtonText: "Cancel", okButtonHandler: { (alert) in
            //OK pressed
            if let captionText = self.textFieldCaption.text{
                self.uploadToFirebaseAfterCaption(caption: captionText)
                alert.dismissAlertView()
            }else{
                self.uploadToFirebaseAfterCaption(caption: "")
                alert.dismissAlertView()
            }
            
            
        }) { (alert) in
            //Cancel Pressed
            alert.dismissAlertView()
        }
        caption.addTextField("Caption", placeHolder: "Write Caption Here")
        
        textFieldCaption = caption.getTextFieldWithIdentifier("Caption")
        textFieldCaption.textColor = UIColor.black
        textFieldCaption?.delegate = self
        textFieldCaption?.maxLength = 50
        textFieldCaption.returnKeyType = .done
        caption.allowTouchOutsideToDismiss = true
        caption.show()
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        originalImage1 = nil
        originalImage2 = nil
        image1.image = nil
        image2.image = nil
        dismiss(animated: true, completion: nil)
        
    }
    
    func showGallery(){
        Config.tabsToShow = [.imageTab]
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
                    let im = cropImageToSquare(image: img)
                    image1.image = im
                    
                }
            }else{
                let asset = images[0].asset
                if let img = convert.conversion(asset){
                    
                    originalImage2 = img
                    let im = cropImageToSquare(image: img)
                    image2.image = im
                }
            }
        }
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func cropImage1(_ sender: Any) {
//        let picker = UIImagePickerController()
//        let cropper = UIImageCropper(cropRatio: 4/3)
//        cropper.picker = picker
//        cropper.delegate = self
//        cropper.image = originalImage1
//        cropper.cancelButtonText = "Cancel"
//        self.present(cropper, animated: true, completion: nil)

        
        let image: UIImage = originalImage1 //Load an image
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        
        //cropViewController.aspectRatioPreset = .preset4x3
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.customAspectRatio = CGSize(width: self.image1.frame.width, height: self.image1.frame.height)
        checkString = "1"
        present(cropViewController, animated: true, completion: nil)
        
        
    }
    func cropViewController(_ cropViewController: CropViewController, didCropImageToRect rect: CGRect, angle: Int) {
//        let croppedImage = originalImage1.crop(rect: rect)
//        //let croppedImage = UIImage(cgImage: finalImage)
//        if checkString == "1"{
//            self.image1.image = croppedImage
//            checkString = "Random"
//        }else if checkString == "0"{
//            self.image2.image = croppedImage
//            checkString = "Random"
//        }
        
        print("RECT IS : \(rect)")
    }
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {

            if checkString == "1"{
                self.image1.image = image
                checkString = "Random"
            }else if checkString == "0"{
                self.image2.image = image
                checkString = "Random"
            }
        dismiss(animated: true, completion: nil)
    }
   
    
    
    @IBAction func cropImage2(_ sender: Any) {
        let image: UIImage = originalImage2 //Load an image
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        cropViewController.aspectRatioPickerButtonHidden = true
        //cropViewController.aspectRatioPreset = .presetCustom
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.customAspectRatio = CGSize(width: self.image1.frame.width, height: self.image1.frame.height)
        
        checkString = "0"
        present(cropViewController, animated: true, completion: nil)
        
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
    func cropImageToSquare(image: UIImage) -> UIImage? {
        var imageHeight = image.size.height
        var imageWidth = image.size.width
        
        if imageHeight > imageWidth {
            imageHeight = imageWidth
        }
        else {
            imageWidth = imageHeight
        }
        
        let size = CGSize(width: imageWidth, height: imageHeight)
        
        let refWidth : CGFloat = CGFloat(image.cgImage!.width)
        let refHeight : CGFloat = CGFloat(image.cgImage!.height)
        
        let x = (refWidth - size.width) / 2
        let y = (refHeight - size.height) / 2
        
        let cropRect = CGRect(x: x, y: y, width: size.height, height: size.width)
        if let imageRef = image.cgImage!.cropping(to: cropRect) {
            return UIImage(cgImage: imageRef, scale: 0, orientation: image.imageOrientation)
        }
        
        return nil
    }
    

}



extension UIImage {
    
    func crop( rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
    
 
}



