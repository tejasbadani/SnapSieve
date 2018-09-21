//
//  ViewUserPostVC.swift
//  SnapSieve
//
//  Created by Tejas Badani on 16/06/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//


import UIKit
import Nuke
import WCLShineButton
import UICircularProgressRing
import ZAlertView
import Firebase
import SDWebImage
import SwiftKeychainWrapper
class ViewUserPostVC: UIViewController {

    @IBOutlet weak var progressView2: UICircularProgressRing!
    @IBOutlet weak var progressView1: UICircularProgressRing!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var extraOptionButton: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: RoundedCorners!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var litLabel: UILabel!
    @IBOutlet weak var heartLabel: UILabel!
    @IBOutlet weak var flowersLabel: UILabel!
    @IBOutlet weak var confusedLabel: UILabel!
    @IBOutlet weak var likeButton: WCLShineButton!
    @IBOutlet weak var litButton: WCLShineButton!
    @IBOutlet weak var heartButton: WCLShineButton!
    @IBOutlet weak var flowersButton: WCLShineButton!
    @IBOutlet weak var confusedButton: WCLShineButton!
    @IBOutlet weak var captionLabel: UILabel!
    let impact = UIImpactFeedbackGenerator(style: .medium)
    var username : String!
    var post : Post!
    var status : String!
    var profileImage : UIImage!
    var id : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //disableApp()
        screenShotDetection()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gesture.numberOfTapsRequired = 1
        extraOptionButton.addGestureRecognizer(gesture)
        
        if let img = profileImage{
            profileImageView.image = img
        }
       
        if let name = username {
            usernameLabel.text = name
        }
        if let stat = status{
            //Random
            statusLabel.text = stat
        }
        if let p = post {
            
            captionLabel.text = p.caption
            //Nuke.loadImage(with: p.imgURL1, into: imageView1)
            //Nuke.loadImage(with: p.imgURL2, into: imageView2)
            imageView1.sd_setImage(with: p.imgURL1, completed: nil)
            imageView2.sd_setImage(with: p.imgURL2, completed: nil)
            //Execute Necessary Thing
            var param1 = WCLShineParams()
            param1.bigShineColor = UIColor(rgb : (0,150,255))
            param1.smallShineColor = UIColor(rgb : (0,150,255))
            param1.animDuration = 2
            likeButton.image = .like
            likeButton.fillColor = UIColor(rgb : (0,150,255))
            likeButton.params = param1
            likeButton.isSelected = true
            likeButton.isEnabled = false
            
            var param2 = WCLShineParams()
            param2.bigShineColor = UIColor(rgb: (255,69,0))
            param2.smallShineColor = UIColor(rgb: (255,69,0))
            param2.animDuration = 2
            litButton.params = param2
            litButton.fillColor = UIColor(rgb: (255,69,0))
            litButton.image = .custom(#imageLiteral(resourceName: "lit"))
            litButton.isSelected = true
            litButton.isEnabled = false
            
            var param3 = WCLShineParams()
            param3.bigShineColor = UIColor.red
            param3.smallShineColor = UIColor.red
            param3.animDuration = 2
            heartButton.params = param3
            heartButton.image = .custom(#imageLiteral(resourceName: "Heart"))
            heartButton.isEnabled = false
            heartButton.isSelected = true
            
            var param4 = WCLShineParams()
            param4.bigShineColor = UIColor.black
            param4.smallShineColor = UIColor.black
            param4.animDuration = 2
            flowersButton.params = param4
            flowersButton.fillColor = UIColor.black
            flowersButton.image = .custom(#imageLiteral(resourceName: "Bouquet"))
            flowersButton.isSelected = true
            flowersButton.isEnabled = false
            
            var param5 = WCLShineParams()
            param5.animDuration = 2
            param5.bigShineColor = UIColor(rgb: (224,172,105))
            param5.smallShineColor = UIColor(rgb: (224,172,105))
            confusedButton.image = .custom(#imageLiteral(resourceName: "Confused"))
            confusedButton.fillColor = UIColor(rgb: (224,172,105))
            confusedButton.params = param5
            confusedButton.isEnabled = false
            confusedButton.isSelected = true
            
            likeLabel.text = "   Likes   \(p.coolCount)"
            litLabel.text = "   Lit   \(p.litCount)"
            heartLabel.text = "   Love   \(p.heartCount)"
            flowersLabel.text = "   RIP   \(p.flowerCount)"
            confusedLabel.text = "   Confused   \(p.confusedCount)"
            let sum = post.votesImage1 + p.votesImage2
            let percentageVotesImage1 = (p.votesImage1/(sum)) * 100
            let percentageVotesImage2 = (p.votesImage2/(sum)) * 100
            if percentageVotesImage1 < 50{
                self.progressView1.innerRingColor = UIColor.red
            }else{
                self.progressView1.innerRingColor = UIColor.green
            }
            
            if percentageVotesImage2 < 50{
                self.progressView2.innerRingColor = UIColor.red
            }else{
                self.progressView2.innerRingColor = UIColor.green
            }
            
            if percentageVotesImage2 > 0 && percentageVotesImage1 > 0{
                self.progressView1.startProgress(to: CGFloat(percentageVotesImage1), duration: 2)
                self.progressView2.startProgress(to: CGFloat(percentageVotesImage2), duration: 2)
                
            }else if percentageVotesImage1 > 0 && percentageVotesImage2 == 0{
                self.progressView2.startProgress(to: 0, duration: 2)
                self.progressView1.startProgress(to: CGFloat(percentageVotesImage1), duration: 2)
                
            }else if percentageVotesImage2 > 0 && percentageVotesImage1 == 0{
                self.progressView1.startProgress(to: 0, duration: 2)
                self.progressView2.startProgress(to: CGFloat(percentageVotesImage2), duration: 2)
                
            }else if percentageVotesImage1.isNaN && percentageVotesImage2.isNaN {
                self.progressView1.startProgress(to: 0, duration: 2)
                self.progressView2.startProgress(to: 0, duration: 2)
            }
            
            
        }
        
    }
    override func viewDidDisappear(_ animated: Bool) {
         NotificationCenter.default.removeObserver(self,name: .UIApplicationUserDidTakeScreenshot ,object: nil)
    }
    func screenShotDetection() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleScreenshot), name: .UIApplicationUserDidTakeScreenshot, object: nil)
    }
    @objc func handleScreenshot(){
        let dict = [post.userID : true]
        print("DICT IS \(dict)")
        DataServices.ds.REF_CURRENT_USER.child("DisabledUsers").updateChildValues(dict)
        //Go back to FeedVC and reload the posts
        //NESTED_BACK = true
        //self.navigationController?.popViewController(animated: true)
        NESTED_BACK = true
        performSegue(withIdentifier: "BackToFeed", sender: nil)
    }
    
    @objc func handleTap(sender : UITapGestureRecognizer){
        impact.impactOccurred()
        showActionSheet()
    }
    
    func showActionSheet(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction = UIAlertAction(title: "Report Post", style: .destructive) { (alert) in
            self.reportUser()
        }
        
        let secondAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
        }
        
        
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        present(alert, animated: true, completion: nil)
    }
    
    func reportUser(){
        let dialog = ZAlertView(title: "Report Post",
                                message: "Are you sure you want to report the post?",
                                isOkButtonLeft: true,
                                okButtonText: "Yes",
                                cancelButtonText: "No",
                                okButtonHandler: { (alertView) -> () in
                                    //Handle the report action
                                    let dict = [self.post.postID : true]
                                    DataServices.ds.REF_REPORTS.updateChildValues(dict)
                                    DataServices.ds.REF_CURRENT_USER.child("reportedPosts").updateChildValues(dict)
                                    alertView.dismissAlertView()
                                    
                                    let dialog2 = ZAlertView(title: "Success",
                                                             message: "The Post has been reported successfully. Thank you for your help to maintain harmony in SnapSieve.",
                                                             closeButtonText: "Okay",
                                                             closeButtonHandler: { alertView in
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

}
