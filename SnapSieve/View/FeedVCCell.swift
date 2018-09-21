//
//  FeedVCCell.swift
//  SnapSieve
//
//  Created by Tejas Badani on 21/04/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
import ZAlertView
import UICircularProgressRing
import WCLShineButton

protocol showUserProtocol{
    func didShowView(index : Int)
}
class FeedVCCell: UITableViewCell {
    let impact = UIImpactFeedbackGenerator(style: .light)

    @IBOutlet weak var progressRing2: UICircularProgressRing!
    @IBOutlet weak var progressRing1: UICircularProgressRing!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var extraOptionImageView: UIImageView!
    @IBOutlet weak var coolButton: WCLShineButton!
    @IBOutlet weak var litButton: WCLShineButton!
    @IBOutlet weak var heartButton: WCLShineButton!
    @IBOutlet weak var flowerButton: WCLShineButton!
    @IBOutlet weak var confusedButton: WCLShineButton!
    @IBOutlet weak var captionLabel: UILabel!
    
    private var _post : Post!
    private var _index : Int!
    var delegate : showUserProtocol!
    var post : Post {
        return _post
    }
    var index : Int{
        return _index
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        impact.prepare()
        let gestureRecog = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecog.numberOfTapsRequired = 1
        
        let gestureRecog1 = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecog1.numberOfTapsRequired = 1
        self.profileImageView.addGestureRecognizer(gestureRecog1)
        self.userNameLabel.addGestureRecognizer(gestureRecog)
        
        var param1 = WCLShineParams()
        param1.bigShineColor = UIColor(rgb : (0,150,255))
        param1.smallShineColor = UIColor(rgb : (0,150,255))
        param1.animDuration = 2
        coolButton.image = .like
        coolButton.fillColor = UIColor(rgb : (0,150,255))
        coolButton.params = param1
        
        var param2 = WCLShineParams()
        param2.bigShineColor = UIColor(rgb: (255,69,0))
        param2.smallShineColor = UIColor(rgb: (255,69,0))
        param2.animDuration = 2
        litButton.params = param2
        litButton.fillColor = UIColor(rgb: (255,69,0))
        litButton.image = .custom(#imageLiteral(resourceName: "lit"))
        
        var param3 = WCLShineParams()
        param3.bigShineColor = UIColor.red
        param3.smallShineColor = UIColor.red
        param3.animDuration = 2
        heartButton.params = param3
        heartButton.image = .custom(#imageLiteral(resourceName: "Heart"))
        
        var param4 = WCLShineParams()
        param4.bigShineColor = UIColor.black
        param4.smallShineColor = UIColor.black
        param4.animDuration = 2
        flowerButton.params = param4
        flowerButton.fillColor = UIColor.black
        flowerButton.image = .custom(#imageLiteral(resourceName: "Bouquet"))
        
        var param5 = WCLShineParams()
        param5.animDuration = 2
        param5.bigShineColor = UIColor(rgb: (224,172,105))
        param5.smallShineColor = UIColor(rgb: (224,172,105))
        confusedButton.image = .custom(#imageLiteral(resourceName: "Confused"))
        confusedButton.fillColor = UIColor(rgb: (224,172,105))
        confusedButton.params = param5
    }

    
    @objc func handleTap(sender : UITapGestureRecognizer){
        impact.impactOccurred()
        indexPath.flatMap {
            delegate.didShowView(index: $0[1])

        }
    }
    

    @IBAction func coolButton(_ sender: WCLShineButton) {
        impact.impactOccurred()
        if sender.isSelected {
            //TODO: Increment the likes
           _post.incrementCool(isIncrement: true)
        }else{
            //TODO: Decrement the likes
            _post.incrementCool(isIncrement: false)
        }
    }
    @IBAction func litButton(_ sender: WCLShineButton) {
        impact.impactOccurred()
        if sender.isSelected {
            //TODO: Increment the likes
            _post.incrementLit(isIncrement: true)
        }else{
            //TODO: Decrement the likes
            _post.incrementLit(isIncrement: false)
        }
    }
    @IBAction func heartButton(_ sender: WCLShineButton) {
        impact.impactOccurred()
        if sender.isSelected {
            //TODO: Increment the likes
            _post.incrementHeart(isIncrement: true)
        }else{
            //TODO: Decrement the likes
            _post.incrementHeart(isIncrement: false)
        }
    }
    @IBAction func flowersButton(_ sender: WCLShineButton) {
        impact.impactOccurred()
        if sender.isSelected {
            //TODO: Increment the likes
            _post.incrementFlowers(isIncrement: true)
        }else{
            //TODO: Decrement the likes
            _post.incrementFlowers(isIncrement: false)
        }
    }
    @IBAction func confusedButton(_ sender: WCLShineButton) {
        impact.impactOccurred()
        if sender.isSelected {
            //TODO: Increment the likes
            _post.incrementConfused(isIncrement: true)
        }else{
            //TODO: Decrement the likes
            _post.incrementConfused(isIncrement: false)
        }
    }
    
    
    func configureCell (post : Post ){
        self._post = post
        self.userNameLabel.text = post.userName
        self.captionLabel.text = post.caption
        self.statusLabel.text = post.status
        checkIfExists()
        
    }
    
    func checkIfExists(){
        DataServices.ds.REF_POSTS.child(_post.postID).child("coolUsers").child(User.u.userID).observe(.value) { (snap) in
            if !(snap.exists()){
                self.coolButton.isSelected = false
            }else{
                self.coolButton.isSelected = true
            }
        }
        
        DataServices.ds.REF_POSTS.child(_post.postID).child("litUsers").child(User.u.userID).observe(.value) { (snap) in
            if !(snap.exists()){
                self.litButton.isSelected = false
            }else{
                self.litButton.isSelected = true
            }
        }
        DataServices.ds.REF_POSTS.child(_post.postID).child("heartUsers").child(User.u.userID).observe(.value) { (snap) in
            if !(snap.exists()){
                self.heartButton.isSelected = false
            }else{
                self.heartButton.isSelected = true
            }
        }
        DataServices.ds.REF_POSTS.child(_post.postID).child("flowersUsers").child(User.u.userID).observe(.value) { (snap) in
            if !(snap.exists()){
                self.flowerButton.isSelected = false
            }else{
                self.flowerButton.isSelected = true
            }
        }
        DataServices.ds.REF_POSTS.child(_post.postID).child("confusedUsers").child(User.u.userID).observe(.value) { (snap) in
            if !(snap.exists()){
                self.confusedButton.isSelected = false
            }else{
                self.confusedButton.isSelected = true
            }
        }
        
    }
   
    override func prepareForReuse() {
        self.imageView2.image = nil
        self.imageView1.image = nil
        self.profileImageView.image = nil
        
    }

}
