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
protocol DeleteButtonProtocol{
    func didShowAlertView(index : Int)
}
class ProfileVCCell: UITableViewCell {
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var totalVotes: UILabel!
    @IBOutlet weak var circularView2: UICircularProgressRingView!
    @IBOutlet weak var circularView1: UICircularProgressRingView!
    var delegate : DeleteButtonProtocol!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        imageView1.image = UIImage()
        imageView2.image = UIImage()
    }
    override func layoutSubviews() {
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(10, 10, 10, 10))
    }
    @IBAction func actionSheetClicked(_ sender: Any) {
        print("EXECUTED 2")
        
        indexPath.flatMap {
            delegate.didShowAlertView(index: $0[1])
            print($0[1])
        }
    }
    
    func configureCell (post : Post ,image1 : UIImage? = nil , image2 : UIImage? = nil ){
        
        let sum = post.votesImage1 + post.votesImage2
        self.totalVotes.text = "Total Votes: \(sum)"
        let percentageVotesImage1 = (post.votesImage1/(sum)) * 100
        let percentageVotesImage2 = (post.votesImage2/(sum)) * 100
        print("VOTES 1 \(percentageVotesImage1)")
        print("VOTES 2 \(percentageVotesImage2)")
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
            print("One")
        }else if percentageVotesImage1 > 0 && percentageVotesImage2 == 0{
            self.circularView2.setProgress(value: 0, animationDuration: 2)
            self.circularView1.setProgress(value: CGFloat(percentageVotesImage1), animationDuration: 2)
            print("Two")
        }else if percentageVotesImage2 > 0 && percentageVotesImage1 == 0{
            self.circularView1.setProgress(value: 0, animationDuration: 2)
            self.circularView2.setProgress(value: CGFloat(percentageVotesImage2), animationDuration: 2)
            print("three")
        }else if percentageVotesImage1.isNaN && percentageVotesImage2.isNaN {
            self.circularView1.setProgress(value: 0, animationDuration: 2)
            self.circularView2.setProgress(value: 0, animationDuration: 2)
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
extension UIResponder {
    
    func next<T: UIResponder>(_ type: T.Type) -> T? {
        return next as? T ?? next?.next(type)
    }
}
extension UITableViewCell {
    
    var tableView: UITableView? {
        return next(UITableView.self)
    }
    
    var indexPath: IndexPath? {
        return tableView?.indexPath(for: self)
    }
}
