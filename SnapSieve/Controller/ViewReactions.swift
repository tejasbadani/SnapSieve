//
//  ViewReactions.swift
//  SnapSieve
//
//  Created by Tejas Badani on 07/10/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import WCLShineButton
import SVProgressHUD
class ViewReactions: UIViewController,UITableViewDelegate,UITableViewDataSource ,showUserProtocol{
  
    @IBOutlet weak var tableView: UITableView!
    var post : Post!
    var likeUsers  = [User]()
    var litUsers = [User]()
    var heartUsers = [User]()
    var flowerUsers = [User]()
    var confusedUsers = [User]()
    var totalUsers = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        if let post = post {
            //Post includes the post ID
            print("Post Exists")
        }
        tableView.delegate = self
        tableView.dataSource = self
         SVProgressHUD.show()
        retrieveData()
    }
    func retrieveData(){
        DataServices.ds.REF_POSTS.child(post.postID).child("coolUsers").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                for obj in snapshot.children{
                    let snap = obj as! DataSnapshot
                    let id = snap.key
                    DataServices.ds.REF_USERS.child(id).observeSingleEvent(of: .value, with: { (shot) in
                        if shot.exists(){
                            
                            if let userDict = shot.value as? [String:Any]{
                                var numberofStars : Float = 0
                                var numberOfUsers : Float = 0
                                var rating : Float = 0
                                var postCount : Float = 0
                                var voteCount : Float = 0
                                var profileURL : String = ""
                                let type = "likeUser"
                                var name : String = ""
                                if let userName = userDict["name"] as? String{
                                    name = userName
                                }
                                if let URL = userDict["profileURL"] as? String{
                                    profileURL = URL
                                }
                                if let rating = userDict["rating"] as? Dictionary<String,Any>{
                                    if let stars = rating["totalStars"] as? Float{
                                        numberofStars = stars
                                    }
                                    if let people = rating["numberOfPeople"] as? Float{
                                        numberOfUsers = people
                                    }
                                }
                                if let numberOfPosts = userDict["numberOfPosts"] as? Float{
                                    postCount = numberOfPosts
                                }
                                if let totalV = userDict["totalVotes"] as? Float{
                                    voteCount = totalV
                                }
                                if numberofStars == 0 && numberOfUsers == 0{
                                    rating = 0
                                }else{
                                    rating = numberofStars/numberOfUsers
                                }
                                let status = Status().calculateStatus(rating: rating, posts: postCount, votes: voteCount)
                                
                                let user = User(userName: name, profileImageURL: profileURL, status: status, type: type, ID: id)
                                print("Likes \(user.user)")
                                self.likeUsers.append(user)
                                self.totalUsers.append(user)
                                self.tableView.insertRows(at: [IndexPath(row: self.totalUsers.count-1, section: 0)], with: UITableViewRowAnimation.fade)
                                self.tableView.endUpdates()
                                SVProgressHUD.dismiss()
                            }
                        }
                    })
                }
            }
        }
        
        //HeartUser
        
        DataServices.ds.REF_POSTS.child(post.postID).child("heartUsers").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                for obj in snapshot.children{
                    let snap = obj as! DataSnapshot
                    let id = snap.key
                    DataServices.ds.REF_USERS.child(id).observeSingleEvent(of: .value, with: { (shot) in
                        if shot.exists(){
                            
                            if let userDict = shot.value as? [String:Any]{
                                var numberofStars : Float = 0
                                var numberOfUsers : Float = 0
                                var rating : Float = 0
                                var postCount : Float = 0
                                var voteCount : Float = 0
                                var profileURL : String = ""
                                let type = "Heart"
                                var name : String = ""
                                if let userName = userDict["name"] as? String{
                                    name = userName
                                }
                                if let URL = userDict["profileURL"] as? String{
                                    profileURL = URL
                                }
                                if let rating = userDict["rating"] as? Dictionary<String,Any>{
                                    if let stars = rating["totalStars"] as? Float{
                                        numberofStars = stars
                                    }
                                    if let people = rating["numberOfPeople"] as? Float{
                                        numberOfUsers = people
                                    }
                                }
                                if let numberOfPosts = userDict["numberOfPosts"] as? Float{
                                    postCount = numberOfPosts
                                }
                                if let totalV = userDict["totalVotes"] as? Float{
                                    voteCount = totalV
                                }
                                if numberofStars == 0 && numberOfUsers == 0{
                                    rating = 0
                                }else{
                                    rating = numberofStars/numberOfUsers
                                }
                                let status = Status().calculateStatus(rating: rating, posts: postCount, votes: voteCount)
                                
                                let user = User(userName: name, profileImageURL: profileURL, status: status, type: type, ID: id)
                                 print("Hearts \(user.user)")
                                self.heartUsers.append(user)
                                self.totalUsers.append(user)
                                self.tableView.insertRows(at: [IndexPath(row: self.totalUsers.count-1, section: 0)], with: UITableViewRowAnimation.fade)
                                self.tableView.endUpdates()
                                SVProgressHUD.dismiss()
                            }
                        }
                    })
                }
            }
        }
        
        //Lit users
        
        DataServices.ds.REF_POSTS.child(post.postID).child("litUsers").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                for obj in snapshot.children{
                    let snap = obj as! DataSnapshot
                    let id = snap.key
                    DataServices.ds.REF_USERS.child(id).observeSingleEvent(of: .value, with: { (shot) in
                        if shot.exists(){
                            
                            if let userDict = shot.value as? [String:Any]{
                                var numberofStars : Float = 0
                                var numberOfUsers : Float = 0
                                var rating : Float = 0
                                var postCount : Float = 0
                                var voteCount : Float = 0
                                var profileURL : String = ""
                                let type = "lit"
                                var name : String = ""
                                if let userName = userDict["name"] as? String{
                                    name = userName
                                }
                                if let URL = userDict["profileURL"] as? String{
                                    profileURL = URL
                                }
                                if let rating = userDict["rating"] as? Dictionary<String,Any>{
                                    if let stars = rating["totalStars"] as? Float{
                                        numberofStars = stars
                                    }
                                    if let people = rating["numberOfPeople"] as? Float{
                                        numberOfUsers = people
                                    }
                                }
                                if let numberOfPosts = userDict["numberOfPosts"] as? Float{
                                    postCount = numberOfPosts
                                }
                                if let totalV = userDict["totalVotes"] as? Float{
                                    voteCount = totalV
                                }
                                if numberofStars == 0 && numberOfUsers == 0{
                                    rating = 0
                                }else{
                                    rating = numberofStars/numberOfUsers
                                }
                                let status = Status().calculateStatus(rating: rating, posts: postCount, votes: voteCount)
                                
                                let user = User(userName: name, profileImageURL: profileURL, status: status, type: type, ID: id)
                                 print("Lit \(user.user)")
                                self.litUsers.append(user)
                                self.totalUsers.append(user)
                                self.tableView.insertRows(at: [IndexPath(row: self.totalUsers.count-1, section: 0)], with: UITableViewRowAnimation.fade)
                                self.tableView.endUpdates()
                                SVProgressHUD.dismiss()
                            }
                        }
                    })
                }
            }
        }
        
        //RIP users
        
        DataServices.ds.REF_POSTS.child(post.postID).child("flowersUsers").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                for obj in snapshot.children{
                    let snap = obj as! DataSnapshot
                    let id = snap.key
                    DataServices.ds.REF_USERS.child(id).observeSingleEvent(of: .value, with: { (shot) in
                        if shot.exists(){
                            
                            if let userDict = shot.value as? [String:Any]{
                                var numberofStars : Float = 0
                                var numberOfUsers : Float = 0
                                var rating : Float = 0
                                var postCount : Float = 0
                                var voteCount : Float = 0
                                var profileURL : String = ""
                                let type = "Bouquet"
                                var name : String = ""
                                if let userName = userDict["name"] as? String{
                                    name = userName
                                }
                                if let URL = userDict["profileURL"] as? String{
                                    profileURL = URL
                                }
                                if let rating = userDict["rating"] as? Dictionary<String,Any>{
                                    if let stars = rating["totalStars"] as? Float{
                                        numberofStars = stars
                                    }
                                    if let people = rating["numberOfPeople"] as? Float{
                                        numberOfUsers = people
                                    }
                                }
                                if let numberOfPosts = userDict["numberOfPosts"] as? Float{
                                    postCount = numberOfPosts
                                }
                                if let totalV = userDict["totalVotes"] as? Float{
                                    voteCount = totalV
                                }
                                if numberofStars == 0 && numberOfUsers == 0{
                                    rating = 0
                                }else{
                                    rating = numberofStars/numberOfUsers
                                }
                                let status = Status().calculateStatus(rating: rating, posts: postCount, votes: voteCount)
                                
                                let user = User(userName: name, profileImageURL: profileURL, status: status, type: type, ID: id)
                                 print("Flower \(user.user)")
                                self.flowerUsers.append(user)
                                self.totalUsers.append(user)
                                self.tableView.insertRows(at: [IndexPath(row: self.totalUsers.count-1, section: 0)], with: UITableViewRowAnimation.fade)
                                self.tableView.endUpdates()
                                SVProgressHUD.dismiss()
                            }
                        }
                    })
                }
            }
        }
        
        //Confused User
        DataServices.ds.REF_POSTS.child(post.postID).child("confusedUsers").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                for obj in snapshot.children{
                    let snap = obj as! DataSnapshot
                    let id = snap.key
                    DataServices.ds.REF_USERS.child(id).observeSingleEvent(of: .value, with: { (shot) in
                        if shot.exists(){
                            
                            if let userDict = shot.value as? [String:Any]{
                                var numberofStars : Float = 0
                                var numberOfUsers : Float = 0
                                var rating : Float = 0
                                var postCount : Float = 0
                                var voteCount : Float = 0
                                var profileURL : String = ""
                                let type = "Confused"
                                var name : String = ""
                                if let userName = userDict["name"] as? String{
                                    name = userName
                                }
                                if let URL = userDict["profileURL"] as? String{
                                    profileURL = URL
                                }
                                if let rating = userDict["rating"] as? Dictionary<String,Any>{
                                    if let stars = rating["totalStars"] as? Float{
                                        numberofStars = stars
                                    }
                                    if let people = rating["numberOfPeople"] as? Float{
                                        numberOfUsers = people
                                    }
                                }
                                if let numberOfPosts = userDict["numberOfPosts"] as? Float{
                                    postCount = numberOfPosts
                                }
                                if let totalV = userDict["totalVotes"] as? Float{
                                    voteCount = totalV
                                }
                                if numberofStars == 0 && numberOfUsers == 0{
                                    rating = 0
                                }else{
                                    rating = numberofStars/numberOfUsers
                                }
                                let status = Status().calculateStatus(rating: rating, posts: postCount, votes: voteCount)
                                
                                let user = User(userName: name, profileImageURL: profileURL, status: status, type: type, ID: id)
                                 print("Confused \(user.user)")
                                self.confusedUsers.append(user)
                                self.totalUsers.append(user)
                                self.tableView.beginUpdates()
                                self.tableView.insertRows(at: [IndexPath(row: self.totalUsers.count-1, section: 0)], with: UITableViewRowAnimation.fade)
                                self.tableView.endUpdates()
                                SVProgressHUD.dismiss()
                            }
                        }
                    })
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ViewReactionsCell{
            let currentUser = totalUsers[indexPath.row]
            cell.delegate = self
            cell.nameLabel.text = currentUser.user
            let url = URL(string: currentUser.userURL)
            if let url = url {
                cell.profileImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "Profile"), options: [.scaleDownLargeImages], completed: nil)
            }
            
            cell.statusLabel.text = currentUser.status
            if currentUser.type == "likeUser"{
                var param1 = WCLShineParams()
                param1.bigShineColor = UIColor(rgb : (0,150,255))
                param1.smallShineColor = UIColor(rgb : (0,150,255))
                param1.animDuration = 2
                cell.reactionImageView.image = .like
                cell.reactionImageView.fillColor = UIColor(rgb : (0,150,255))
                cell.reactionImageView.params = param1
                cell.reactionImageView.isSelected = true
                cell.reactionImageView.isEnabled = false
            }else if currentUser.type == "Heart"{
                var param3 = WCLShineParams()
                param3.bigShineColor = UIColor.red
                param3.smallShineColor = UIColor.red
                param3.animDuration = 2
                cell.reactionImageView.fillColor = UIColor.red
                cell.reactionImageView.params = param3
                cell.reactionImageView.image = .custom(#imageLiteral(resourceName: "Heart"))
                cell.reactionImageView.isEnabled = false
                cell.reactionImageView.isSelected = true
            }else if currentUser.type == "lit"{
                var param2 = WCLShineParams()
                param2.bigShineColor = UIColor(rgb: (255,69,0))
                param2.smallShineColor = UIColor(rgb: (255,69,0))
                param2.animDuration = 2
                cell.reactionImageView.params = param2
                cell.reactionImageView.fillColor = UIColor(rgb: (255,69,0))
                cell.reactionImageView.image = .custom(#imageLiteral(resourceName: "lit"))
                cell.reactionImageView.isSelected = true
                cell.reactionImageView.isEnabled = false
            }else if currentUser.type == "Bouquet"{
                var param4 = WCLShineParams()
                param4.bigShineColor = UIColor.black
                param4.smallShineColor = UIColor.black
                param4.animDuration = 2
                cell.reactionImageView.params = param4
                cell.reactionImageView.fillColor = UIColor.black
                cell.reactionImageView.image = .custom(#imageLiteral(resourceName: "Bouquet"))
                cell.reactionImageView.isSelected = true
                cell.reactionImageView.isEnabled = false
            }else {
                var param5 = WCLShineParams()
                param5.animDuration = 2
                param5.bigShineColor = UIColor(rgb: (224,172,105))
                param5.smallShineColor = UIColor(rgb: (224,172,105))
                cell.reactionImageView.image = .custom(#imageLiteral(resourceName: "Confused"))
                cell.reactionImageView.fillColor = UIColor(rgb: (224,172,105))
                cell.reactionImageView.params = param5
                cell.reactionImageView.isEnabled = false
                cell.reactionImageView.isSelected = true
            }
            return cell
        }else{
            return UITableViewCell()
        }
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    func didShowView(index: Int) {
        //When a row is clicked in the tableView
        performSegue(withIdentifier: "viewUser2", sender: index)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "viewUser2"{
            let viewUser = segue.destination as! ViewUserVC
            let index = sender as! Int
            viewUser.userName = totalUsers[index].user
            viewUser.userIDsample = totalUsers[index].ID
            viewUser.profileURL = totalUsers[index].userURL
        }
    }
}
