//
//  ShadowImage_ProfileVC.swift
//  SnapSieve
//
//  Created by Tejas Badani on 17/02/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit

class ShadowImage_ProfileVC: UIImageView {

    override func awakeFromNib() {
        //let shadowSize : CGFloat = 5.0
        //let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
        //                                         y: -shadowSize / 2,
        //                                       width: self.frame.size.width + shadowSize,
        //                                     height: self.frame.size.height + shadowSize))
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 0.5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        //self.layer.shadowPath = shadowPath.cgPath
    }
}
