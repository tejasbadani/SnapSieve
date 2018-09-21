//
//  LoadImages.swift
//  SnapSieve
//
//  Created by Tejas Badani on 23/07/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import Foundation
import UIKit
let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    //var imageUrlString: String?
    
    func loadImageUsingUrlString(urlString: String) {
        
        //imageUrlString = urlString
        
        let url = NSURL(string: urlString)
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, respones, error) in
            
            if error != nil {
                print(error)
                return
            }
            
            DispatchQueue.main.async {
                let imageToCache = UIImage(data: data!)
                
//                if self.imageUrlString == urlString {
//                    self.image = imageToCache
//                }
                self.image = imageToCache
                
                imageCache.setObject(imageToCache!, forKey: urlString as AnyObject)
            }
          
            
        }).resume()
    }
    
}
