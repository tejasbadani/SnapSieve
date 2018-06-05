//
//  RoundedCorners.swift
//  SnapSieve
//
//  Created by Tejas Badani on 21/04/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit

class RoundedCorners: UIImageView {
    override func awakeFromNib() {
        self.layer.cornerRadius = 7.0
        //self.layer.borderWidth = 1.0
        //self.layer.borderColor = UIColor.black.cgColor
        
    }

}
