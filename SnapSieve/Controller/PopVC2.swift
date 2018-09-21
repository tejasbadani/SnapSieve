//
//  PopVC2.swift
//  SnapSieve
//
//  Created by Tejas Badani on 01/07/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit

class PopVC2: UIViewController {

    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var previousLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let c = User.u.currentStatus{
            currentLabel.text = c
        }
        if let p = User.u.previousStatus{
            previousLabel.text = p
        }
        
        showAnimate()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func returnPressed(_ sender: Any) {
        removeAnimate()
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
    

}
