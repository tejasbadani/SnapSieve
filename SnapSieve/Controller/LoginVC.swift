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
import ZAlertView
import SVProgressHUD
import FBSDKCoreKit
import Nuke
import Alamofire
import AlamofireImage
import SwiftyJSON
class LoginVC: UIViewController,UIScrollViewDelegate,UITextFieldDelegate,GIDSignInUIDelegate {
  
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var googleImage: UIImageView!
    @IBOutlet weak var facebookImage: UIImageView!
    @IBOutlet weak var upperView: UIView!
    var name : String!
    var profileURL : String!
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
    typealias username = (Bool) -> Void
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ZAlertView.positiveColor            = UIColor.color("#669999")
        ZAlertView.negativeColor            = UIColor.color("#CC3333")
        ZAlertView.blurredBackground        = false
        ZAlertView.showAnimation            = .bounceBottom
        ZAlertView.hideAnimation            = .bounceTop
        ZAlertView.initialSpringVelocity    = 0.9
        ZAlertView.duration                 = 2
        ZAlertView.textFieldTextColor       = UIColor.brown
        ZAlertView.textFieldBackgroundColor = UIColor.color("#EFEFEF")
        ZAlertView.textFieldBorderColor     = UIColor.color("#669999")
        
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
        introVC.hero.modalAnimationType = animations[2]
        hero.replaceViewController(with: introVC)
        hero.dismissViewController()
    }
    @objc func facebookLogin(gestureRecogniser : UITapGestureRecognizer){
        
            let faceBookLogin = FBSDKLoginManager()
            faceBookLogin.logOut()
            faceBookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
                if error != nil{
                    print("Error occured")
                    //print(error)
                    self.showAlert()
                }else if result?.isCancelled == true{
                    print("User Cancelled login")
                   self.showAlert()
                }else{
                    SVProgressHUD.setBackgroundColor(UIColor.lightGray)
                    SVProgressHUD.show()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
//                        if let _ = FBSDKAccessToken.current(){
//                            self.fetchUserProfile()
//                        }
                        self.firebaseAuth(credential: credential, completionHandler: {(check) in
                            self.transition()
                            SVProgressHUD.dismiss()
                            
                        })
                        
                    })
                    
                }
            }
       
    }
    
    
    func showAlert(){
        let dialog = ZAlertView(title: "Oops",
                                message: "There seems to be a problem. Please try again.",
                                closeButtonText: "Okay",
                                closeButtonHandler: { alertView in
                                    alertView.dismissAlertView()
        }
        )
        dialog.allowTouchOutsideToDismiss = false
        dialog.show()
    }
    
    func transition(){
//        let voteVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Vote") as! VoteVC
//        voteVC.hero.modalAnimationType = animations[3]
//        hero.replaceViewController(with: voteVC)
        performSegue(withIdentifier: "facebook", sender: nil)
    }
    @objc func googleLogin(gestureRecogniser : UITapGestureRecognizer){
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
  
    func firebaseAuth(credential : AuthCredential,completionHandler : @escaping (Bool) -> Void){
        let group = DispatchGroup()
        Auth.auth().signIn(with: credential) { (user, error) in
            if(error != nil){
                group.enter()
                print("Could not authenticate")
                self.showAlert()
                group.leave()
            }else {
                if let user = user {
                    group.enter()
                    self.fetchUserProfile(completionHandler: { (check) in
                        let userData = ["provider":credential.provider , "name" : self.name, "profileURL" : self.profileURL]
                        print("THE ID : \(user.uid)")
                        self.completeSignIn(id: user.uid, userData: userData as! Dictionary<String, String>)
                        group.leave()
                    })
                    
                }
            }
            group.notify(queue: .main, execute: {
                
                completionHandler(true)
            })
            
        }
        
    }
    func getFinalProfileURL(url : String, completion : @escaping (_ finaleURL : String)->()){
        
        Alamofire.request(url).responseData{ response in
            
            let json = JSON( response.result.value )
            let urlFinal = json["data"]["url"].stringValue
            completion(urlFinal)

        }
       
        
    }
    func completeSignIn(id : String, userData : Dictionary<String,String>)
    {
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        DataServices.ds.createFirebaseUser(uid: id, userData: userData)
        
        
    }
    func fetchUserProfile(completionHandler : @escaping username)
    {
        let grp = DispatchGroup()
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, email, name"])
        grp.enter()
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                grp.leave()
            }
            else
            {
                
                //TODO:Get name from the data
                if let dict = result as? Dictionary<String,String>{
                    if let name = dict["name"]{
                        KeychainWrapper.standard.set(name, forKey: KEY_NAME)
                        self.name = name
                    }else{
                        KeychainWrapper.standard.set("Unknown", forKey: KEY_NAME)
                        self.name = "Unknown"
                    }
                    if let id = dict["id"]{
                        let url = "http://graph.facebook.com/\(id)/picture?height=1024&redirect=false"
                        self.profileURL = url
                        
                    }else{
                        self.profileURL = ""
                    }
                }else{
                    KeychainWrapper.standard.set("Unknown", forKey: KEY_NAME)
                    self.name = "Unkown"
                }
                grp.leave()
                
            }
            
        })
        grp.notify(queue: .main) {
            self.getFinalProfileURL(url: self.profileURL, completion: { (url) in
                self.profileURL = url
                completionHandler(true)
            })
            
        }
      
    }
}
