//
//  ViewPostVC.swift
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

var didDeletePost : Bool = false
class ViewPostVC: UIViewController {
    
    @IBOutlet weak var progressView2: UICircularProgressRing!
    @IBOutlet weak var progressView1: UICircularProgressRing!
    @IBOutlet weak var totalVotesLabel: UILabel!
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapgesture.numberOfTapsRequired  = 1
        self.extraOptionButton.addGestureRecognizer(tapgesture)
        if let img = profileImage{
            profileImageView.image = img
        }
        if let name = username {
            usernameLabel.text = name
            
        }
        if let stat = status{
            statusLabel.text = stat
        }
        if let p = post {
            captionLabel.text = p.caption
            totalVotesLabel.text = "Total Votes : \(Int(p.votesImage1 + p.votesImage2))"
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
            heartButton.fillColor = UIColor.red
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
    @objc func handleTap (sender : UITapGestureRecognizer){
        impact.impactOccurred()
        didShowAlertView()
    }

    func didShowAlertView() {
        //TODO - Show action sheet and delete the post
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction = UIAlertAction(title: "Delete Post", style: .destructive) { (alert) in
            self.deletePost()
        }
        let secondAction = UIAlertAction(title: "Stop Votes", style: .default) { (alert) in
            self.stopVotes()
        }
        let thirdAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
        }
        let shareAction = UIAlertAction(title: "Share Most Voted Image", style: .default) { (alert) in
            self.shareImage()
        }
        
        
        alert.addAction(firstAction)
        if post.isVotingEnabled == true{
            alert.addAction(secondAction)
        }
        alert.addAction(shareAction)
        alert.addAction(thirdAction)
        present(alert, animated: true, completion: nil)
        
    }
   
    func deletePost(){
        let dialog = ZAlertView(title: "Delete Post",
                                message: "Are you sure you want to delete the post?",
                                isOkButtonLeft: true,
                                okButtonText: "Yes",
                                cancelButtonText: "No",
                                okButtonHandler: { (alertView) -> () in
                                    
                                    let postID = self.post.postID
                                   
                                    DataServices.ds.REF_CURRENT_USER.child("numberOfPosts").observeSingleEvent(of: .value) { (snapshot) in
                                        if snapshot.exists(){
                                            var postNumber = snapshot.value as! Int
                                            if postNumber <= 0{
                                                 postNumber = 0
                                            }else{
                                                postNumber = postNumber - 1
                                            }
                                           
                                    DataServices.ds.REF_CURRENT_USER.child("numberOfPosts").setValue(postNumber)
                                        }else{
                                            DataServices.ds.REF_CURRENT_USER.child("numberOfPosts").setValue(0)
                                        }
                                    }
                                    DataServices.ds.REF_CURRENT_USER.child("posts").child(postID).removeValue(completionBlock: { (err, ref) in
                                        if let error = err{
                                            print(error)
                                            self.errorDisplay()
                                            
                                        }else{
                                            DataServices.ds.REF_POST_ID.child(postID).removeValue(completionBlock: { (err, ref) in
                                                if let error = err {
                                                    print(error)
                                                    self.errorDisplay()
                                                }else{
                                                    DataServices.ds.REF_POSTS.child(postID).removeValue(completionBlock: { (err, referene) in
                                                        if let error = err{
                                                            print(error)
                                                            self.errorDisplay()
                                                        }else{
                                                            let storage = Storage.storage()
                                                            
                                                                let url1 = self.post.imgURL1.absoluteString
                                                                let url2 = self.post.imgURL2.absoluteString
                                                    
                                                            storage.reference(forURL: url1).delete(completion: { (error) in
                                                                if let err = error{
                                                                    print(err)
                                                                }else{
                                                                    //Success
                                                                }
                                                            })
                                                            storage.reference(forURL: url2).delete(completion: { (error) in
                                                                if let err = error{
                                                                    print(err)
                                                                }
                                                                else{
                                                                    //Success
                                                                }
                                                            })
                                                            //:TODO Do the things here
                                                            
                                                            //self.posts.remove(at: index)
                                                            didDeletePost = true
                                                            
                                                            
                                                            alertView.dismissAlertView()
                                                            let dialog2 = ZAlertView(title: "Success",
                                                                                     message: "Your Post has been deleted successfully!",
                                                                                     closeButtonText: "Okay",
                                                                                     closeButtonHandler: { alertView in
                                                                                        //self.tableView.reloadData()
                                                                                        self.navigationController?.popViewController(animated: true)
                                                                                        alertView.dismissAlertView()
                                                            }
                                                            )
                                                            dialog2.allowTouchOutsideToDismiss = true
                                                            dialog2.show()
                                                        }
                                                    })
                                                }
                                            })
                                        }
                                    })
                                    
        },
                                cancelButtonHandler: { (alertView) -> () in
                                    alertView.dismissAlertView()
        }
        )
        dialog.show()
        dialog.allowTouchOutsideToDismiss = true
    }
    func stopVotes(){
        let dialog = ZAlertView(title: "Stop Votes",
                                message: "Are you sure you want to stop voting on this post ? You cannot resume voting later. (Feature coming soon)",
                                isOkButtonLeft: true,
                                okButtonText: "Yes",
                                cancelButtonText: "No",
                                okButtonHandler: { (alertView) -> () in
                                    
                                    let postID = self.post.postID
                                    DataServices.ds.REF_POSTS.child(postID).child("isVotingEnabled").setValue(false)
                                    alertView.dismissAlertView()
                                    let dialog2 = ZAlertView(title: "Success",
                                                             message: "The post will no longer be voted on.",
                                                             closeButtonText: "Cool!",
                                                             closeButtonHandler: { alertView in
                                                                alertView.dismissAlertView()
                                    }
                                    )
                                    dialog2.allowTouchOutsideToDismiss = true
                                    dialog2.show()
                                    
                                    
                                    
        },
                                cancelButtonHandler: { (alertView) -> () in
                                    alertView.dismissAlertView()
        }
        )
        dialog.show()
        dialog.allowTouchOutsideToDismiss = true
        
    }
    
    func shareImage(){
        //Image Goes in there
        //var image : UIImage!
        if post.votesImage1 > post.votesImage2{
            //Set image as the corresponding image
            if let img = imageView1.image{
                //image = img
                showActivityController(image: img)
            }else{
                errorDisplay()
            }
            
        }else if post.votesImage2 > post.votesImage1{
            //Set image as the correspoonding image
            if let img = imageView2.image{
                //image = img
                showActivityController(image: img)
            }else{
                errorDisplay()
            }
        }else{
            //Both are equal so give choice or just display alert saying not yet
            let dialog2 = ZAlertView(title: "Oops ",
                                     message: "Seems like there is no majority yet. Try when there is a majority!",
                                     closeButtonText: "Okay",
                                     closeButtonHandler: { alertView in
                                        alertView.dismissAlertView()
            }
            )
            dialog2.allowTouchOutsideToDismiss = true
            dialog2.show()
        }
        
    }
    func showActivityController(image : UIImage){
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC,animated:true , completion: nil)
    }
    
    
    func errorDisplay(){
        let dialog2 = ZAlertView(title: "Oops ",
                                 message: "There seemed to be an error. Please try again later",
                                 closeButtonText: "Okay",
                                 closeButtonHandler: { alertView in
                                    alertView.dismissAlertView()
        }
        )
        dialog2.allowTouchOutsideToDismiss = true
        dialog2.show()
    }
    
    @IBAction func viewReactors(_ sender: Any) {
        performSegue(withIdentifier: "view", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "view"{
            let destination = segue.destination as! ViewReactions
            destination.post = post
        }
    }
}


























