//
//  Internet Access.swift
//  SnapSieve
//
//  Created by Tejas Badani on 20/02/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import Foundation
import SystemConfiguration
import Alamofire
class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
