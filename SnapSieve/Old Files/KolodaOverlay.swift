//
//  KolodaOverview.swift
//  SnapSieve
//
//  Created by Tejas Badani on 09/02/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

//import UIKit
//import Koloda
//private let overlayRightImageName = "noOverlayImage"
//private let overlayLeftImageName = "noOverlayImage"
//class KolodaOverlay: OverlayView {
//
//    @IBOutlet lazy var overlayImageView: UIImageView! = {
//        [unowned self] in
//
//        var imageView = UIImageView(frame: CGRect(x: self.center.x, y: self.center.y, width: 64, height: 64))
//        self.addSubview(imageView)
//
//        return imageView
//        }()
//    override var overlayState: SwipeResultDirection? {
//        didSet {
//            switch overlayState {
//            case .left? :
//                overlayImageView.image = UIImage(named: overlayLeftImageName)
//            case .right? :
//                overlayImageView.image = UIImage(named: overlayRightImageName)
//            default:
//                overlayImageView.image = nil
//            }
//        }
//    }
//}
