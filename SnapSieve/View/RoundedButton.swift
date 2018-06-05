//
//  RoundedButton.swift
//  SnapSieve
//
//  Created by Tejas Badani on 26/05/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
@IBDesignable
class RoundedButton: UIButton {

    @IBInspectable
    public var roundedCorner : CGFloat = 20.0{
        didSet{
            self.layer.cornerRadius = self.roundedCorner
        }
    }

}
