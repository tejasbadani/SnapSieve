//
//  RoundedView.swift
//  SnapSieve
//
//  Created by Tejas Badani on 26/05/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
@IBDesignable
class RoundedView: UIView {

    @IBInspectable
    public var cornerRadius : CGFloat = 10.0{
        didSet{
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    @IBInspectable
    public var borderWidth : CGFloat = 1.0{
        didSet{
            self.layer.borderWidth = self.borderWidth
        }
    }
    @IBInspectable
    public var borderColor : UIColor = UIColor.white{
        didSet{
            self.layer.borderColor = self.borderColor.cgColor
        }
    }

}
