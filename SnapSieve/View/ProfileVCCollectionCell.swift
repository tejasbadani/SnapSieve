//
//  ProfileVCCollectionCell.swift
//  
//
//  Created by Tejas Badani on 15/06/18.
//

import UIKit

class ProfileVCCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
    private var _post : Post!
    var post : Post {
        return _post
    }
    func configureCell(post : Post){
        self._post = post
    }
    
    override func awakeFromNib() {
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.5
        //self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 1.0
        self.layer.cornerRadius = 5.0
    }
}
