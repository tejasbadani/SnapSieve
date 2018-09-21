//
//  TutorialButton.swift
//  SnapSieve
//
//  Created by Tejas Badani on 31/07/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
@IBDesignable
class TutorialButton: UIButton {

    @IBInspectable
    private var cornerRadius : CGFloat = 25{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
  
    override func awakeFromNib() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.0

    }

}
