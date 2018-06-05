//
//  PopUpViewController.swift
//  SnapSieve
//
//  Created by Tejas Badani on 26/05/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {

    @IBOutlet weak var votes: UILabel!
    @IBOutlet weak var remainingPosts: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let votesNumber = User.u.totalVotes{
             self.votes.text = "\(votesNumber)"
        }
        if let remainingPostsNumber = User.u.remainingPosts{
            self.remainingPosts.text = "\(remainingPostsNumber)"
        }
       
        
        self.showAnimate()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func okayPressed(_ sender: Any) {
        self.removeAnimate()
        //self.view.removeFromSuperview()
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
