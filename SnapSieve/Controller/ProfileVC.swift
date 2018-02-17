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
class ProfileVC: UIViewController,UITableViewDelegate,UITableViewDataSource{

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
                            let postObject = Post(img1URL: URL1, img2URL: URL2, votes1: votes1, votes2: votes2 , postID : key as! String)
                            self.posts.append(postObject)
                            print(self.posts)
                            group.leave()
                        }
                    })
                }
                
            }
            
            group.notify(queue: .main) {
                print("BROOO")
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
                
                return cell
            }else{
                return ProfileVCCell()
            }
        }else{
            let dialog = ZAlertView(title: "Oops",
                                    message: "Seems like you havent posted anything yet! Post something to get your results!",
                                    closeButtonText: "Okay",
                                    closeButtonHandler: { alertView in
                                        alertView.dismissAlertView()
                                        self.dismiss(animated: true, completion: nil)
            }
            )
            dialog.allowTouchOutsideToDismiss = true
            dialog.show()
            return UITableViewCell()
        }
       
    }
    
   
    @IBAction func goBack(_ sender: Any) {
       dismiss(animated: true, completion: nil)
    }
    
}
