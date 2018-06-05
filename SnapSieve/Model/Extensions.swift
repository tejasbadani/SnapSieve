//
//  Extensions.swift
//  SnapSieve
//
//  Created by Tejas Badani on 13/05/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import Foundation
import Gallery
import UIKit
import ZAlertView
import Firebase
extension FeedVC : GalleryControllerDelegate{
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        imagesE = []
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
                self.performSegue(withIdentifier: "Camera1", sender: nil)
                
                
            })
            
        }else if images.count == 0 || images.count == 1{
            //Alert View saying you have to choose two images
            let dialog = ZAlertView(title: "Oops",
                                    message: "Seems like you haven't picked enough photos. Pick two photos!",
                                    closeButtonText: "Okay",
                                    closeButtonHandler: { alertView in
                                        alertView.dismissAlertView()
            }
            )
            dialog.allowTouchOutsideToDismiss = true
            dialog.show()
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
    
    func uploadImage(){
        if didFinishRetrievingInfo == true{
            if (User.u.remainingPosts > 0){
                Config.tabsToShow = [.imageTab]
                Config.Camera.imageLimit = 2
                let gallery = GalleryController()
                gallery.delegate = self
                present(gallery, animated: true, completion: nil)
            }else{
                //Alert to tell user nope
                let dialog = ZAlertView(title: "Oops",
                                        message: "Seems like you haven't voted enough. Vote more to post!",
                                        closeButtonText: "Okay",
                                        closeButtonHandler: { alertView in
                                            alertView.dismissAlertView()
                }
                )
                dialog.allowTouchOutsideToDismiss = true
                dialog.show()
            }
        }else{
            let dialog = ZAlertView(title: "One moment!",
                                    message: "Loading your information...",
                                    closeButtonText: "Okay",
                                    closeButtonHandler: { alertView in
                                        alertView.dismissAlertView()
            }
            )
            dialog.allowTouchOutsideToDismiss = true
            dialog.show()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Camera1" {
            let uploadVC = segue.destination as! UploadImagesVC
            uploadVC.img1 = imagesE.first
            uploadVC.img2 = imagesE.last
        }
    }
}
