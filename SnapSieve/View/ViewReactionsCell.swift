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
    var delegate : showUserProtocol!
    @IBOutlet weak var reactionImageView: WCLShineButton!
    @IBOutlet weak var profileImageView: RoundedCorners!
    let impact = UIImpactFeedbackGenerator(style: .light)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let gesture1 = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        gesture1.numberOfTapsRequired = 1
        profileImageView.addGestureRecognizer(gesture1)
        
        let gesture2 = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        gesture2.numberOfTapsRequired = 1
        nameLabel.addGestureRecognizer(gesture2)
    }
    @objc func handleTap(sender : UITapGestureRecognizer){
        impact.impactOccurred()
        indexPath.flatMap {
            delegate.didShowView(index: $0[1])
        }
    }

}
