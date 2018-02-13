//
//  IntroductionManager.swift
//  SnapSieve
//
//  Created by Tejas Badani on 26/01/18.
//  Copyright © 2018 Tejas Badani. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
var returnedFromLogin : Bool = false
import CoreLocation
class IntroductionManager: UIPageViewController,UIPageViewControllerDataSource,UIPageViewControllerDelegate,CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    var pageControl = UIPageControl()
    fileprivate lazy var pages: [UIViewController] = {
        return [
            self.getViewController(withIdentifier: "Intro1"),
            self.getViewController(withIdentifier: "Intro2"),
            self.getViewController(withIdentifier: "Intro3")
        ]
    }()
    override func viewWillAppear(_ animated: Bool) {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController
    {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.dataSource = self
        self.delegate   = self
        
        if returnedFromLogin == true{
            setViewControllers([pages.last!], direction: .forward, animated: true, completion: nil)
            configurePageControl(pageNumber: 2)
        }else{
            if let firstVC = pages.first
            {
                configurePageControl(pageNumber : 0)
                setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
            }
        }
        
    }
    override func viewDidLayoutSubviews() {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID){

            performSegue(withIdentifier: "segue", sender: nil)
        }
    }
    
    func configurePageControl(pageNumber : Int) {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 140 ,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = pages.count
        self.pageControl.currentPage = pageNumber
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.gray
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = pages.index(of: pageContentViewController)!
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        //guard nextIndex < pages.count else { return pages.first }
        
        guard pages.count > nextIndex else { return nil         }
        
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0          else { return nil }
        guard pages.count > previousIndex else { return nil }
        return pages[previousIndex]
    }
    
    
    

}
