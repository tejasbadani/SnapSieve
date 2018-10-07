//
//  ViewReactionsCell.swift
//  SnapSieve
//
//  Created by Tejas Badani on 07/10/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
import WCLShineButton
class ViewReactionsCell: UITableViewCell {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
   
    @IBOutlet weak var reactionImageView: WCLShineButton!
    @IBOutlet weak var profileImageView: RoundedCorners!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
