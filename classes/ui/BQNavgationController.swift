// *******************************************
//  File Name:      BQNavigationController.swift
//  Author:         MrBai
//  Created Date:   2021/6/2 2:14 PM
//
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import UIKit

public class BQNavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    private var panGestureVC: UIViewController?

    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }

    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count == 1 { viewController.hidesBottomBarWhenPushed = true }

        super.pushViewController(viewController, animated: animated)
    }

    // MARK: - UINavigationControllerDelegate

    public func navigationController(_: UINavigationController, didShow viewController: UIViewController, animated _: Bool) {
        panGestureVC = viewControllers.count <= 1 ? nil : viewController
    }

    // MARK: - UIGestureRecognizerDelegate

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if interactivePopGestureRecognizer == gestureRecognizer {
            // Begin to pop only when top view controller is current child view controller but not root view controller
            if let panVc = panGestureVC, panVc == topViewController {
                return panVc.navGestureBack
            }
        }
        return true
    }
}

public extension UIViewController {
    private enum AssociatedKeys {
        static var navBack: Void?
    }

    var navGestureBack: Bool {
        get {
            if let back = objc_getAssociatedObject(self, &AssociatedKeys.navBack) as? Bool {
                return back
            }
            return true
        }
        set {
            if let nav = navigationController, nav is BQNavigationController {
                objc_setAssociatedObject(self, &AssociatedKeys.navBack, newValue, .OBJC_ASSOCIATION_ASSIGN)
            }
        }
    }
}
