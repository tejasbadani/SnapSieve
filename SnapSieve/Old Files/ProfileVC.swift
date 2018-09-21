//
//  ProfileVC.swift
//  SnapSieve
//
//  Created by Tejas Badani on 28/01/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.



import UIKit
import Firebase
import FirebaseStorage
import SVProgressHUD
import ZAlertView
import SDWebImage
import Photos
import Nuke


class ProfileVC: UIViewController,UITableViewDelegate,UITableViewDataSource,DeleteButtonProtocol{
    
    static var imageCache  : NSCache<NSString,UIImage> = NSCache()
    @IBOutlet weak var tableView: UITableView!
    var posts = [Post]()
    var image1Array  = [UIImage]()
    var image2Array  = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        SVProgressHUD.dismiss()
        retrieveDataFromFirebase()
        // Do any additional setup after loading the view.
    }
    
    func didShowAlertView(index : Int) {
        //TODO - Show action sheet and delete the post
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction = UIAlertAction(title: "Delete Post", style: .destructive) { (alert) in
            self.deletePost(index: index)
        }
        let secondAction = UIAlertAction(title: "Stop Votes", style: .default) { (alert) in
            self.stopVotes(index: index)
        }
        let thirdAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
        }
        let shareAction = UIAlertAction(title: "Share Most Voted Image", style: .default) { (alert) in
            self.shareImage(index: index)
        }
        
        
        alert.addAction(firstAction)
        if posts[index].isVotingEnabled == true{
            alert.addAction(secondAction)
        }
        alert.addAction(shareAction)
        alert.addAction(thirdAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func deletePost(index : Int){
        let dialog = ZAlertView(title: "Report Post",
                                message: "Are you sure you want to delete the post?",
                                isOkButtonLeft: true,
                                okButtonText: "Yes",
                                cancelButtonText: "No",
                                okButtonHandler: { (alertView) -> () in
                                    
                                    let postID = self.posts[index].postID
                                    print("POST ID: \(postID)")
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
                                                            let url1 = self.posts[index].imgURL1.absoluteString
                                                            let url2 = self.posts[index].imgURL2.absoluteString
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
                                                            self.posts.remove(at: index)
                                                            self.retrieveDataFromFirebase()
                                                            alertView.dismissAlertView()
                                                            let dialog2 = ZAlertView(title: "Success",
                                                                                     message: "Your Post has been deleted successfully!",
                                                                                     closeButtonText: "Okay",
                                                                                     closeButtonHandler: { alertView in
                                                                                        //self.tableView.reloadData()
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
    
    
    func stopVotes(index: Int){
        let dialog = ZAlertView(title: "Stop Votes",
                                message: "Are you sure you want to stop voting on this post ? You cannot resume voting later.",
                                isOkButtonLeft: true,
                                okButtonText: "Yes",
                                cancelButtonText: "No",
                                okButtonHandler: { (alertView) -> () in
                                    
                                    let postID = self.posts[index].postID
                                    DataServices.ds.REF_POST_ID.child(postID).removeValue(completionBlock: { (err, ref) in
                                        if let error = err {
                                            print(error)
                                            alertView.dismissAlertView()
                                            
                                            self.errorDisplay()
                                        }else{
                                            alertView.dismissAlertView()
                                            //TODO
                                            self.posts[index].isVotingEnabled = false
                                            DataServices.ds.REF_POSTS.child(self.posts[index].postID).removeAllObservers()
                                            DataServices.ds.REF_POSTS.child(self.posts[index].postID).child("isVotingEnabled").setValue(false)
                                            //self.tableView.reloadData()
                                            let dialog2 = ZAlertView(title: "Success",
                                                                     message: "Voting has been stopped on this post!",
                                                                     closeButtonText: "Okay",
                                                                     closeButtonHandler: { alertView in
                                                                        alertView.dismissAlertView()
                                            }
                                            )
                                            dialog2.allowTouchOutsideToDismiss = true
                                            dialog2.show()
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
    
    
    func shareImage(index : Int){
        //Image Goes in there
        //var image : UIImage!
        if posts[index].votesImage1 > posts[index].votesImage2{
            //Set image as the corresponding image
            if let img = posts[index].image1{
                //image = img
                showActivityController(image: img)
            }else{
                errorDisplay()
            }
            
        }else if posts[index].votesImage2 > posts[index].votesImage1{
            //Set image as the correspoonding image
            if let img = posts[index].image2{
                //image = img
                showActivityController(image: img)
            }else{
                errorDisplay()
            }
        }else{
            //Both are equal so give choice or just display alert saying not yet
            let dialog2 = ZAlertView(title: "Oops ",
                                     message: "Seems like there is no majority yet. Try when there is a majority !",
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
    
    func convertStringToURl(url1 : String , url2: String,completionHere: @escaping (_ url1 : URL? , _ url2 : URL?)->()){
        let reference1 = Storage.storage().reference(forURL: url1)
        reference1.downloadURL(completion: { (url, err) in
            if err == nil{
                
                if let url1 = url {
                    
                    let reference2 = Storage.storage().reference(forURL: url2)
                    reference2.downloadURL(completion: { (url_2, err) in
                        if err == nil{
                            
                            if let url2 = url_2 {
                                
                                completionHere(url1,url2)
                                
                            }else{
                                completionHere(nil,nil)
                            }
                        }else{
                            completionHere(nil,nil)
                        }
                    })
                    
                }else{
                    completionHere(nil,nil)
                }
            }else{
                completionHere(nil,nil)
                
            }
        })
    }
    
    func retrieveDataFromFirebase(){
        
        self.posts = []
        let group = DispatchGroup()
        DataServices.ds.REF_CURRENT_USER.child("posts").observe(.value) { (snapshot) in
            
            if let dic = snapshot.value as? Dictionary<String,Bool>{
                for (key, _) in dic{
                    group.enter()
                    DataServices.ds.REF_POSTS.child(key).observe(.value, with: { (postDataSnapshot) in
                        
                        if let postDict = postDataSnapshot.value as? Dictionary<String,Any>{
                            var URL1 : String!
                            var URL2 : String!
                            var votes1: Float!
                            var votes2: Float!
                            var isVoteEnabled : Bool = true
                            var userID : String!
                            var coolCount : Int!
                            var litCount : Int!
                            var heartCount : Int!
                            var flowersCount : Int!
                            var confusedCount : Int!
                            if let image1 = postDict["image1"] as? Dictionary<String,AnyObject> {
                                if let URL = image1["URL"]{
                                    URL1 = URL as! String
                                }else{
                                    URL1 = "gs://snapsieve.appspot.com/post-pics/Error.png"
                                }
                                if let votes = image1["votes"]{
                                    print(votes)
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
                                    print(URL)
                                    URL2 = URL as! String
                                }else{
                                    URL2 = "gs://snapsieve.appspot.com/post-pics/Error.png"
                                }
                                if let votes = image2["votes"]{
                                    print(votes)
                                    votes2 = votes as! Float
                                }else{
                                    votes2 = 0
                                }
                            }else{
                                URL2 = "gs://snapsieve.appspot.com/post-pics/Error.png"
                                votes2 = 0
                            }
                            
                            if  let isVoteEnable = postDict["isVotingEnabled"] as? Bool {
                                isVoteEnabled = isVoteEnable
                            }
                            
                            if let coolC = postDict["cool"] as? Int{
                                coolCount = coolC
                            }else{
                                coolCount = 0
                            }
                            if let litC = postDict["lit"] as? Int{
                                litCount = litC
                                
                            }else{
                                litCount = 0
                            }
                            if let heartC = postDict["heart"] as? Int{
                                heartCount = heartC
                            }else{
                                heartCount = 0
                            }
                            if let flowersC = postDict["flowers"] as? Int{
                                flowersCount = flowersC
                            }else{
                                flowersCount = 0
                            }
                            if let confusedC  = postDict["confused"] as? Int{
                                confusedCount = confusedC
                            }else{
                                confusedCount = 0
                            }
                            
                            self.convertStringToURl(url1: URL1, url2: URL2, completionHere: { (url1, url2) in
                                if let url1_1 = url1 , let url2_2 = url2{
                                    let postObject = Post(img1URL: url1_1, img2URL: url2_2, votes1: votes1, votes2: votes2 , postID : key , isVotingEnabled : isVoteEnabled , coolC : coolCount , litC : litCount , heartC : heartCount , flowersC : flowersCount , confusedC : confusedCount)
                                    self.posts.append(postObject)
                                    group.leave()
                                    DataServices.ds.REF_POSTS.child(key).removeAllObservers()
                                }else{
                                    group.leave()
                                }
                                
                            })
                            
                        }
                    })
                }
                
            }
            
            group.notify(queue: .main) {
                if self.posts.count <= 0{
                    let dialog = ZAlertView(title: "Oops",
                                            message: "Seems like you havent posted anything yet! Post something to get your results!",
                                            closeButtonText: "Okay",
                                            closeButtonHandler: { alertView in
                                                alertView.dismissAlertView()
                                                self.navigationController?.popViewController(animated: true)
                    }
                    )
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
                }
                self.image1Array = Array(repeating: #imageLiteral(resourceName: "Empty"), count: self.posts.count)
                self.image2Array = Array(repeating: #imageLiteral(resourceName: "Empty"), count: self.posts.count)
                self.tableView.reloadData()
            }
        }
        
    }

   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if posts.count>0{
            let currentPost = posts[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: "UserPost") as? ProfileVCCell{
                
                cell.configureCell(post: currentPost)
                Nuke.loadImage(with: currentPost.imgURL1, into: cell.imageView1)
                Nuke.loadImage(with: currentPost.imgURL2, into: cell.imageView2)
                cell.delegate = self
                
                return cell
            }else{
                return ProfileVCCell()
            }
        }else{
           
            return UITableViewCell()
        }
       
    }
    
   
    @IBAction func goBack(_ sender: Any) {
        
       dismiss(animated: true, completion: nil)
    }
    
}
