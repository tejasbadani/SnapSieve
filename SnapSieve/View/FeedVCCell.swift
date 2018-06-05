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
class FeedVCCell: UITableViewCell {

    @IBOutlet weak var progressRing2: UICircularProgressRingView!
    @IBOutlet weak var progressRing1: UICircularProgressRingView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var postDescriptionLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var extraOptionImageView: UIImageView!
    
    private var _post : Post!
    
    var post : Post {
        return _post
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        
    }



    func configureCell (post : Post){
        self._post = post
        self.userNameLabel.text = post.userName
        self.postDescriptionLabel.text = post.caption
    }
    func configureCell1 (post : Post){
        
    }
    override func prepareForReuse() {
        self.imageView2.image = nil
        self.imageView1.image = nil
        self.profileImageView.image = nil
        
    }

}
