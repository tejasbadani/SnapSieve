//
//  HandleSelection.swift
//  SnapSieve
//
//  Created by Tejas Badani on 03/05/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import Foundation
import ZAlertView
import UICircularProgressRing
class HandleSelection{
    
    
    func voteCheck(){
        if User.u.votes == 0{
            let dialog = ZAlertView(title: "Well Done!",
                                    message: "You now have acccess to one more post! ",
                                    closeButtonText: "Okay",
                                    closeButtonHandler: { alertView in
                                        alertView.dismissAlertView()
            }
            )
            dialog.allowTouchOutsideToDismiss = true
            dialog.show()
        }
    }
    func animateCircularView1(totalVotes : Float , numeratorVotes : Float , circularView : UICircularProgressRing , imageView : UIImageView){
        
        circularView.isHidden = false
        
        //circularView.font.withSize(12)
        let  votePercentage :Float = Float((numeratorVotes/totalVotes) * 100)
        imageView.alpha = 0.8
        if (votePercentage < 50){
            circularView.innerRingColor = UIColor.red
        }else{
            circularView.innerRingColor = UIColor.green
        }
        
        circularView.startProgress(to: CGFloat(votePercentage), duration: 3) {
            
        }
        
    }
    
}
