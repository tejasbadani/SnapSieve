//
//  PHAssetToImage.swift
//  SnapSieve
//
//  Created by Tejas Badani on 01/02/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import Foundation
import Photos
class PHToImage{
    func conversion (_ asset : PHAsset) -> UIImage?{
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img
    }
}
