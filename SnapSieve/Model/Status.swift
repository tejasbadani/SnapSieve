//
//  Status.swift
//  SnapSieve
//
//  Created by Tejas Badani on 29/06/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import Foundation
class Status{
    
    func calculateStatus(rating : Float,posts : Float , votes : Float) -> String {
        let s = (rating + votes) * posts
        if s==0 || s.isNaN {
            return "SnapSieve Beginner"
        }else if s>0 && s<=61{
            return "SnapSieve Rookie"
        }else if s>61 && s<=157{
            return "Casual SnapSiever"
        }else if s>157 && s<=1230 {
            return "SnapSievomaniac"
        }else if s>1230 && s<=4725{
            return "SnapSieve Knight"
        }else if s>4725 && s<=12900{
            return "SnapSieve Lord"
        }else if s>12900{
            return "SnapSieve Emperor"
        }else{
            return "Oops.Couldn't load info."
        }
    }
}
