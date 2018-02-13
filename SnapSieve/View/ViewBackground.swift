//
//  ViewBackground.swift
//  SnapSieve
//
//  Created by Tejas Badani on 31/01/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit

class ViewBackground: UIView {

    override func awakeFromNib() {
        self.layer.cornerRadius = 7.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
    }

}
