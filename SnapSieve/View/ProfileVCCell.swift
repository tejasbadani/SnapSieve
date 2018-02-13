//
//  ProfileVCCell.swift
//  SnapSieve
//
//  Created by Tejas Badani on 28/01/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit

class ProfileVCCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(10, 10, 10, 10))
    }
}
