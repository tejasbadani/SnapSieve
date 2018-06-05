//
//  AppDelegate.swift
//  SnapSieve
//
//  Created by Tejas Badani on 25/01/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import SwiftKeychainWrapper
import SVProgressHUD
import Fabric
import UserNotifications
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        Fabric.sharedSDK().debug = true
        
        
        // iOS 10 support
         if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            // iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 8 support
        else if #available(iOS 8, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 7 support
        else {
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
        
        return true
    }
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            var signedIn : Bool =  GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
             signedIn = signedIn ? signedIn : FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: nil)
            return signedIn
    }
    
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        // Print it to console
        print("APNs device token: \(deviceTokenString)")
        
        // Persist it in your backend in case it's new
    }
    
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
    }
    
    // Push notification received
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Print notification payload data
        print("Push notification received: \(data)")
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            // ...
            print(error)
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        if let error = error {
            // ...
            
            print("error \(error)")
            return
        }
        SVProgressHUD.setBackgroundColor(UIColor.lightGray)
        SVProgressHUD.show()
        
        firebaseAuth(credential: credential , user : user)
        
        
    }
    func firebaseAuth(credential : AuthCredential , user: GIDGoogleUser!){
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if(error != nil){
                print("Could not authenticate")
            }else {
                if let user = user {
                    let abc = user.photoURL?.absoluteString
                    print("\n URL FOR PHOTO \(abc)")
                    KeychainWrapper.standard.set(user.displayName!, forKey: KEY_NAME)
                    let userData = ["provider":credential.provider , "name": user.displayName ,"profileURL" : user.photoURL?.absoluteString ]
                    self.completeSignIn(id: user.uid, userData: userData as! Dictionary<String, String>)
                    
                }
            }
            
        }
        
    }
    
    func completeSignIn(id : String, userData : Dictionary<String,String>)
    {
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        showLoginScreen()
        DataServices.ds.createFirebaseUser(uid: id, userData: userData)
        
        
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication : sourceApplication,annotation:annotation)
        
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func showLoginScreen(){
        let feed = UIStoryboard.getMainStoryboard().instantiateViewController(withIdentifier: "Nav") as! UINavigationController
        UIApplication.shared.delegate!.window!!.rootViewController = feed
        
        SVProgressHUD.dismiss()
    }


}
extension UIStoryboard{
    //returns storyboard from default bundle if bundle paased as nil.
    public class func getMainStoryboard() -> UIStoryboard{
        return UIStoryboard(name: "Main", bundle: nil)
    }
}

