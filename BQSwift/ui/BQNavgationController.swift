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
 
    private var panGestureVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if viewControllers.count == 1 { viewController.hidesBottomBarWhenPushed = true }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    // MARK: - UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        panGestureVC = viewControllers.count <= 1 ? nil : viewController
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if interactivePopGestureRecognizer == gestureRecognizer {
            // Begin to pop only when top view controller is current child view controller but not root view controller
            if let panVc = panGestureVC, panVc == topViewController {
                return panVc.navGestureBack
            }
        }
        return true
    }
}

extension UIViewController {
    private struct AssociatedKeys {
        static var navBack: Void?
    }
    
    open var navGestureBack: Bool {
        get {
            if let back = objc_getAssociatedObject(self, &AssociatedKeys.navBack) as? Bool {
                return back
            }
            return true
        }
        set {
            if let nav = self.navigationController, nav is BQNavgationController {
                objc_setAssociatedObject(self, &AssociatedKeys.navBack, newValue, .OBJC_ASSOCIATION_ASSIGN)
            }
        }
    }
}
