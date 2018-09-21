//
//  IntroVC3.swift
//  SnapSieve
//
//  Created by Tejas Badani on 26/01/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
import Hero

class IntroVC3: UIViewController {

    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var lowerView: UIView!
    var animations: [HeroDefaultAnimationType] = [
        .push(direction: .left),
        .pull(direction: .left),
        .slide(direction: .up),
        .zoomSlide(direction: .left),
        .cover(direction: .up),
        .uncover(direction: .up),
        .pageIn(direction: .left),
        .pageOut(direction: .left),
        .fade,
        .zoom,
        .zoomOut,
        .none
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognsier = UISwipeGestureRecognizer(target: self, action: #selector(transiton))
        gestureRecognsier.direction = .up
        self.lowerView.addGestureRecognizer(gestureRecognsier)
        
        let gestureRecogArrow = UITapGestureRecognizer(target: self, action: #selector(transiton))
        gestureRecogArrow.numberOfTapsRequired = 1
        arrowImage.addGestureRecognizer(gestureRecogArrow)
        
        let tapLowerView = UITapGestureRecognizer(target: self, action: #selector(transiton))
        tapLowerView.numberOfTapsRequired = 1
        self.lowerView.addGestureRecognizer(tapLowerView)
        
    }

    @objc func transiton(){
        returnedFromLogin = true
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        loginVC.hero.modalAnimationType = animations[2]
        hero.replaceViewController(with: loginVC)
    }


}
