// *******************************************
//  File Name:      BQNavgationController.swift       
//  Author:         MrBai
//  Created Date:   2021/6/2 2:14 PM
//    
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit
 
class BQNavgationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
 
    // Current child view controller, but not root view controller
    private var currentNotRootVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count == 1 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        currentNotRootVC = viewControllers.count <= 1 ? nil : viewController
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if interactivePopGestureRecognizer == gestureRecognizer {
            // Begin to pop only when top view controller is current child view controller but not root view controller
            return currentNotRootVC == topViewController
        }
        return true
    }
 
}
