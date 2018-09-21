//
//  ProfileVCCell.swift
//  SnapSieve
//
//  Created by Tejas Badani on 28/01/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
import WCLShineButton
import UICircularProgressRing
import SVProgressHUD
import Firebase
import SDWebImage
protocol DeleteButtonProtocol{
    func didShowAlertView(index : Int)
}
class ProfileVCCell: UITableViewCell {
    private var _post : Post!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var totalVotes: UILabel!
    @IBOutlet weak var circularView2: UICircularProgressRing!
    @IBOutlet weak var circularView1: UICircularProgressRing!
    @IBOutlet weak var coolButton: WCLShineButton!
    @IBOutlet weak var litButton: WCLShineButton!
    @IBOutlet weak var heartButton: WCLShineButton!
    @IBOutlet weak var flowerButton: WCLShineButton!
    @IBOutlet weak var confusedButton: WCLShineButton!
    @IBOutlet weak var coolCount: UILabel!
    @IBOutlet weak var litCount: UILabel!
    @IBOutlet weak var heartCount: UILabel!
    @IBOutlet weak var flowersCount: UILabel!
    @IBOutlet weak var confusedCount: UILabel!
    
    var post : Post{
        return _post
    }
    var delegate : DeleteButtonProtocol!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
       
        var param1 = WCLShineParams()
        param1.bigShineColor = UIColor(rgb: (153,152,38))
        param1.smallShineColor = UIColor(rgb: (102,102,102))
        param1.animDuration = 2
        coolButton.image = .like
        coolButton.params = param1
        coolButton.isSelected = true
        coolButton.isEnabled = false
        
        var param2 = WCLShineParams()
        param2.bigShineColor = UIColor(rgb: (153,152,38))
        param2.smallShineColor = UIColor(rgb: (102,102,102))
        param2.animDuration = 2
        litButton.params = param2
        litButton.image = .custom(#imageLiteral(resourceName: "lit"))
        litButton.isSelected = true
        litButton.isEnabled = false
        
        var param3 = WCLShineParams()
        param3.bigShineColor = UIColor(rgb: (153,152,38))
        param3.smallShineColor = UIColor(rgb: (102,102,102))
        param3.animDuration = 2
        heartButton.params = param3
        heartButton.image = .custom(#imageLiteral(resourceName: "Heart"))
        heartButton.isEnabled = false
        heartButton.isSelected = true
        
        var param4 = WCLShineParams()
        param4.bigShineColor = UIColor(rgb: (153,152,38))
        param4.smallShineColor = UIColor(rgb: (102,102,102))
        param4.animDuration = 2
        flowerButton.params = param4
        flowerButton.image = .custom(#imageLiteral(resourceName: "Bouquet"))
        flowerButton.isSelected = true
        flowerButton.isEnabled = false
        
        var param5 = WCLShineParams()
        param5.animDuration = 2
        param5.bigShineColor = UIColor(rgb: (153,152,38))
        param5.smallShineColor = UIColor(rgb: (102,102,102))
        confusedButton.image = .custom(#imageLiteral(resourceName: "Confused"))
        confusedButton.params = param5
        confusedButton.isEnabled = false
        confusedButton.isSelected = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        imageView1.image = nil
        imageView2.image = nil
    }
    override func layoutSubviews() {
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(10, 10, 10, 10))
    }
    @IBAction func actionSheetClicked(_ sender: Any) {
        indexPath.flatMap {
            delegate.didShowAlertView(index: $0[1])
        }
    }
    
    func configureCell (post : Post  ){
        
        self._post = post
        coolCount.text = "\(post.coolCount)"
        litCount.text = "\(post.litCount)"
        heartCount.text = "\(post.heartCount)"
        flowersCount.text = "\(post.flowerCount)"
        confusedCount.text = "\(post.confusedCount)"
        let sum = post.votesImage1 + post.votesImage2
        self.totalVotes.text = "Total Votes: \(Int(sum))"
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
        
//        let ref1 = Storage.storage().reference(forURL: post.image1URL)
//        let ref2 = Storage.storage().reference(forURL: post.image2URL)
//
//        ref1.downloadURL(completion: { (url, error) in
//            if error != nil{
//                print("ERROR OCCURED")
//            }else{
//
//                //cell.imageView1.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "PlaceholderImage"))
//                //self.image1Array.insert(cell.imageView2.image!, at: indexPath.row)
//                self.imageView1.sd_setImage(with: url, completed: nil)
//
//                
//            }
//        })
//
//        ref2.downloadURL(completion: { (url, error) in
//            if error != nil{
//                print("ERROR OCCURED")
//            }else{
//                self.imageView2.sd_setImage(with: url, completed: nil)
//            }
//        })
//
        
        if percentageVotesImage2 > 0 && percentageVotesImage1 > 0{
            self.circularView1.startProgress(to: CGFloat(percentageVotesImage1), duration: 2)
            self.circularView2.startProgress(to: CGFloat(percentageVotesImage2), duration: 2)
           
        }else if percentageVotesImage1 > 0 && percentageVotesImage2 == 0{
            self.circularView2.startProgress(to: 0, duration: 2)
            self.circularView1.startProgress(to: CGFloat(percentageVotesImage1), duration: 2)
           
        }else if percentageVotesImage2 > 0 && percentageVotesImage1 == 0{
            self.circularView1.startProgress(to: 0, duration: 2)
            self.circularView2.startProgress(to: CGFloat(percentageVotesImage2), duration: 2)
            
        }else if percentageVotesImage1.isNaN && percentageVotesImage2.isNaN {
            self.circularView1.startProgress(to: 0, duration: 2)
            self.circularView2.startProgress(to: 0, duration: 2)
        }
        
        //self.imageView1.sd_setImage(with: post.image1URL, completed: nil)
        //self.imageView2.sd_setImage(with: post.image2URL, completed: nil)
        
       
//        if image1 == nil && image2 == nil{
//            let ref1 = Storage.storage().reference(forURL: post.image1URL)
//            ref1.getData(maxSize : 2 * 1024 * 1024, completion : {(data,error) in
//                //grp.enter()
//                if error != nil{
//                    print("Unable to download image")
//                }else{
//
//                    print("Image Downloaded from storage ----")
//                    if let imageData = data{
//                        if let img = UIImage(data: imageData){
//                            ProfileVC.imageCache.setObject(img, forKey: post.image1URL as NSString)
//                            self.imageView1.image = img
//                        }
//                    }
//                }
//            })
//
//
//            let ref2 = Storage.storage().reference(forURL: post.image2URL)
//            ref2.getData(maxSize : 2 * 1024 * 1024, completion : {(data,error) in
//                //grp.enter()
//                if error != nil{
//                    print("Unable to download image")
//                }else{
//                    print("Image Downloaded from storage")
//                    if let imageData = data{
//                        if let img = UIImage(data: imageData){
//                            ProfileVC.imageCache.setObject(img, forKey: post.image2URL as NSString)
//                            self.imageView2.image = img
//                        }
//                    }
//                }
//            })
//        }else{
//            self.imageView1.image = image1
//            self.imageView2.image = image2
//        }
     
        
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
