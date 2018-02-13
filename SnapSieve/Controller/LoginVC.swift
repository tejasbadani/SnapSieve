//
//  LoginVC.swift
//  SnapSieve
//
//  Created by Tejas Badani on 26/01/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
import Hero
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import SwiftKeychainWrapper
class LoginVC: UIViewController,UIScrollViewDelegate,UITextFieldDelegate,GIDSignInUIDelegate {
  

    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var googleImage: UIImageView!
    @IBOutlet weak var facebookImage: UIImageView!
    @IBOutlet weak var upperView: UIView!
    var animations: [HeroDefaultAnimationType] = [
        .push(direction: .left),
        .pull(direction: .left),
        .slide(direction: .down),
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
        
        let gestureRecogiser = UISwipeGestureRecognizer(target: self, action: #selector(transtionBack))
        gestureRecogiser.direction = .down
        self.upperView.addGestureRecognizer(gestureRecogiser)
        
        let gestureRecogniser2 = UITapGestureRecognizer(target: self, action: #selector(facebookLogin))
        gestureRecogniser2.numberOfTapsRequired = 1
        self.facebookImage.addGestureRecognizer(gestureRecogniser2)
        
        let gestureRecogniser3 = UITapGestureRecognizer(target: self, action: #selector(googleLogin))
        gestureRecogniser3.numberOfTapsRequired = 1
        self.googleImage.addGestureRecognizer(gestureRecogniser3)
        
        let gestureRecogniser4 = UITapGestureRecognizer(target: self, action: #selector(transtionBack))
        gestureRecogniser4.numberOfTapsRequired = 1
        self.arrowImage.addGestureRecognizer(gestureRecogniser4)
    }
    
    @objc func transtionBack(){
        let introVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Intro") as! IntroductionManager
        introVC.heroModalAnimationType = animations[2]
        hero_replaceViewController(with: introVC)
        hero_dismissViewController()
    }
    @objc func facebookLogin(gestureRecogniser : UITapGestureRecognizer){
        
            let faceBookLogin = FBSDKLoginManager()
            faceBookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
                if error != nil{
                    print("Error occured")
                }else if result?.isCancelled == true{
                    print("User Cancelled login")
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                        self.firebaseAuth(credential: credential, completionHandler: {(check) in
                            self.transition()
                            
                        })
                        
                    })
                    
                }
            }
       
    }
    
    func transition(){
        let voteVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Vote") as! VoteVC
        voteVC.heroModalAnimationType = animations[3]
        hero_replaceViewController(with: voteVC)
    }
    @objc func googleLogin(gestureRecogniser : UITapGestureRecognizer){
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
  
    func firebaseAuth(credential : AuthCredential,completionHandler : @escaping (Bool) -> Void){
        let group = DispatchGroup()
        Auth.auth().signIn(with: credential) { (user, error) in
            if(error != nil){
                print("Could not authenticate")
            }else {
                if let user = user {
                    group.enter()
                    let userData = ["provider":credential.provider]
                     self.completeSignIn(id: user.uid, userData: userData)
                   
                    group.leave()
                }
            }
            group.notify(queue: .main, execute: {
                completionHandler(true)
            })
            
        }
        
    }
    
    func completeSignIn(id : String, userData : Dictionary<String,String>)
    {
        print("EXECUTED")
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        DataServices.ds.createFirebaseUser(uid: id, userData: userData)
        
        
    }
 
    
    
    
    
}
