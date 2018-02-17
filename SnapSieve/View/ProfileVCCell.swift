//
//  ProfileVCCell.swift
//  SnapSieve
//
//  Created by Tejas Badani on 28/01/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
import UICircularProgressRing
import SVProgressHUD
import Firebase
class ProfileVCCell: UITableViewCell {
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var totalVotes: UILabel!
    @IBOutlet weak var circularView2: UICircularProgressRingView!
    @IBOutlet weak var circularView1: UICircularProgressRingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(10, 10, 10, 10))
    }
    @IBAction func actionSheetClicked(_ sender: Any) {
       
    }
    
    func configureCell (post : Post ,image1 : UIImage? = nil , image2 : UIImage? = nil){
        
        let sum = post.votesImage1 + post.votesImage2
        self.totalVotes.text = "Total Votes: \(sum)"
        let percentageVotesImage1 = (post.votesImage1/(sum)) * 100
        let percentageVotesImage2 = (post.votesImage2/(sum)) * 100
        
        if percentageVotesImage1 < 50{
            self.circularView1.innerRingColor = UIColor.red
        }else{
             self.circularView1.innerRingColor = UIColor.green
        }
        
        if percentageVotesImage2 < 50{
            self.circularView2.innerRingColor = UIColor.red
        }else{
            self.circularView2.innerRingColor = UIColor.green
        }
        
        if percentageVotesImage2 > 0 && percentageVotesImage1 > 0{
            self.circularView1.setProgress(value: CGFloat(percentageVotesImage1), animationDuration: 2)
            self.circularView2.setProgress(value: CGFloat(percentageVotesImage2), animationDuration: 2)
        }
        
        
       
        if image1 == nil && image2 == nil{
            let ref1 = Storage.storage().reference(forURL: post.image1URL)
            ref1.getData(maxSize : 2 * 1024 * 1024, completion : {(data,error) in
                //grp.enter()
                if error != nil{
                    print("Unable to download image")
                }else{
                    
                    print("Image Downloaded from storage")
                    if let imageData = data{
                        if let img = UIImage(data: imageData){
                            ProfileVC.imageCache.setObject(img, forKey: post.image1URL as NSString)
                            self.imageView1.image = img
                        }
                    }
                }
            })
            
            
            let ref2 = Storage.storage().reference(forURL: post.image2URL)
            ref2.getData(maxSize : 2 * 1024 * 1024, completion : {(data,error) in
                //grp.enter()
                if error != nil{
                    print("Unable to download image")
                }else{
                    print("Image Downloaded from storage")
                    if let imageData = data{
                        if let img = UIImage(data: imageData){
                            ProfileVC.imageCache.setObject(img, forKey: post.image2URL as NSString)
                            self.imageView2.image = img
                        }
                    }
                }
            })
        }else{
            self.imageView1.image = image1
            self.imageView2.image = image2
        }
     
        
    }
    
}
