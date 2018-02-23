//
//  ProfileVC.swift
//  SnapSieve
//
//  Created by Tejas Badani on 28/01/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SVProgressHUD
import ZAlertView
class ProfileVC: UIViewController,UITableViewDelegate,UITableViewDataSource,DeleteButtonProtocol{
    func didShowAlertView(index : Int) {
        //TODO - Show action sheet and delete the post
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction = UIAlertAction(title: "Delete Post", style: .destructive) { (alert) in
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
                                                print("Failed")
                                                self.errorDisplay()
                                                
                                            }else{
                                                DataServices.ds.REF_POST_ID.child(postID).removeValue(completionBlock: { (err, ref) in
                                                    if let error = err {
                                                        print(error)
                                                        print("FAILED")
                                                        self.errorDisplay()
                                                    }else{
                                                        DataServices.ds.REF_POSTS.child(postID).removeValue(completionBlock: { (err, referene) in
                                                            if let error = err{
                                                                print(error)
                                                                print("Failed")
                                                                self.errorDisplay()
                                                            }else{
                                                                let storage = Storage.storage()
                                                                let url1 = self.posts[index].image1URL
                                                                let url2 = self.posts[index].image2URL
                                                                storage.reference(forURL: url1).delete(completion: { (error) in
                                                                    if let err = error{
                                                                        print(err)
                                                                        print("FAILED IMG")
                                                                    }else{
                                                                        //Success
                                                                    }
                                                                })
                                                                storage.reference(forURL: url2).delete(completion: { (error) in
                                                                    if let err = error{
                                                                        print(err)
                                                                        print("FAILED IMG 2")
                                                                    }
                                                                    else{
                                                                       //Success
                                                                    }
                                                                })
                                                                self.posts.remove(at: index)
                                                                self.tableView.reloadData()
                                                                alertView.dismissAlertView()
                                                                let dialog2 = ZAlertView(title: "Success",
                                                                                         message: "Your Post has been deleted successfully!",
                                                                                         closeButtonText: "Okay",
                                                                                         closeButtonHandler: { alertView in
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
        let secondAction = UIAlertAction(title: "Stop Votes ", style: .default) { (alert) in
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
                                                print("FAILED")
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
        let thirdAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
        }
        
        if posts[index].isVotingEnabled == true{
            alert.addAction(secondAction)
        }
        alert.addAction(firstAction)
        alert.addAction(thirdAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    static var imageCache  : NSCache<NSString,UIImage> = NSCache()
    @IBOutlet weak var tableView: UITableView!
    var posts = [Post]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        retrieveDataFromFirebase()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        
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
    func retrieveDataFromFirebase(){
        
        //SVProgressHUD.setBackgroundColor(UIColor.lightGray)
        //SVProgressHUD.show()
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
                            if let image1 = postDict["image1"] as? Dictionary<String,AnyObject> {
                                if let URL = image1["URL"]{
                                    print(URL)
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
                                print("EXECUTED B")
                                URL1 = "gs://snapsieve.appspot.com/post-pics/Error.png"
                                votes2 = 1
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
                                print("EXECUTED B")
                                URL2 = "gs://snapsieve.appspot.com/post-pics/Error.png"
                                votes2 = 0
                            }
                            
                            if  let isVoteEnable = postDict["isVotingEnabled"] as? Bool {
                                print("VOTE ENABLED \(isVoteEnable)")
                                isVoteEnabled = isVoteEnable
                            }
                            //TODO: Retrieve bool from the same post. Is voting post. While posting , add another element of isVoting
                            let postObject = Post(img1URL: URL1, img2URL: URL2, votes1: votes1, votes2: votes2 , postID : key as! String , isVotingEnabled : isVoteEnabled)
                            self.posts.append(postObject)
                            print(self.posts)
                            group.leave()
                        }
                    })
                }
                
            }
            
            group.notify(queue: .main) {
                print("BROOO")
                if self.posts.count <= 0{
                    let dialog = ZAlertView(title: "Oops",
                                            message: "Seems like you havent posted anything yet! Post something to get your results!",
                                            closeButtonText: "Okay",
                                            closeButtonHandler: { alertView in
                                                alertView.dismissAlertView()
                                                self.dismiss(animated: true, completion: nil)
                    }
                    )
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
                    //DataServices.ds.REF_POSTS.removeAllObservers()
                }
                self.tableView.reloadData()
//                self.tableView.delegate = self
//                self.tableView.dataSource = self
                
               // SVProgressHUD.dismiss()
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
                
                if let image = ProfileVC.imageCache.object(forKey: currentPost.image1URL as NSString) , let image2 = ProfileVC.imageCache.object(forKey: currentPost.image2URL as NSString)  {
                    
                    cell.configureCell(post: currentPost, image1: image , image2: image2)
                }else{
                    
                    cell.configureCell(post: currentPost)
                }
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
