//
//  DeepLinkNavigator.swift
//  SnapSieve
//
//  Created by Tejas Badani on 17/07/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import Foundation
public class DeepLinkNavigator{
    static let shared = DeepLinkNavigator()
    init() { }
     func proceedToDeeplink(_ type: DeepLinkType) {
        switch type{
        case .profile:
            break
            //Change View
        case .votePost:
            print("POST IS EXECUTED ")
            break
            //Change View
        }
    }
}
