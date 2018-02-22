//
//  ShadowImage.swift
//  SnapSieve
//
//  Created by Tejas Badani on 02/02/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit

class ShadowImage: UIImageView {

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
       
        //self.layer.shadowPath = shadowPath.cgPath
    }

}
