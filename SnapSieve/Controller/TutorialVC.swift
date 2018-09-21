//
//  TutorialVC.swift
//  SnapSieve
//
//  Created by Tejas Badani on 31/07/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
class TutorialVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nextButton: TutorialButton!
    private var index : Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        //nextButton.titleLabel?.text = "Next"
        nextButton.setTitle("Next", for: .normal)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    @IBAction func nextButtonPressed(_ sender: Any) {
        if index == 0{
            //Go to the next screen
            imageView.image = #imageLiteral(resourceName: "Tutorial 2")
            index += 1
        }else if index == 1{
            //Go to the third screen and change button text to done
            nextButton.setTitle("Next", for: .normal)
            imageView.image = #imageLiteral(resourceName: "Tutorial 3")
            index += 1
            
        }else if index == 2{
            //Go to the Fourth screen and change button text to done
            nextButton.setTitle("Exit", for: .normal)
            imageView.image = #imageLiteral(resourceName: "Tutorial 4")
            index += 1
        }else if index == 3{
            //Exit this VC
            KeychainWrapper.standard.set("Something", forKey: TUTORIAL_UID)
            dismiss(animated: true, completion: nil)
        }
        
    }
    
}
