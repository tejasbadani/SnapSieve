//
//  TextViewBorder.swift
//  SnapSieve
//
//  Created by Tejas Badani on 28/06/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit

class TextViewBorder: UITextView {

    override func awakeFromNib() {
        self.layer.borderWidth = 0.3
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 2.0
    }

}
