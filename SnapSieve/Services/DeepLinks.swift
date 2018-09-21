//
//  DeepLinks.swift
//  SnapSieve
//
//  Created by Tejas Badani on 17/07/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import Foundation
import SwiftyJSON
enum DeepLinkType{
    case votePost
    case profile
    
}
let DeepLinker = DeepLinkManager()
class DeepLinkManager{
    fileprivate init() {}
    private var deeplinkType: DeepLinkType?
    func checkDeepLink(){
        guard let deepLinkType = deeplinkType else {return}
        DeepLinkNavigator().proceedToDeeplink(deepLinkType)
        self.deeplinkType = nil
    }
    func handleRemoteNotification(_ notification: [AnyHashable: Any]) {
        
        deeplinkType = NotificationParser.shared.handleNotification(notification)
    }
}
class NotificationParser{
    static let shared = NotificationParser()
    private init() { }
    func handleNotification(_ userInfo: [AnyHashable : Any]) -> DeepLinkType? {
        
        print("HERE THE DATA IS \(userInfo)")
        if let type = userInfo["type"] as? String{
                if (type == "vote"){
                     return DeepLinkType.votePost
                }else if (type == "profile"){
                     return DeepLinkType.profile
                }
        }
        return nil
    }
}


