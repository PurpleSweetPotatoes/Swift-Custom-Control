// *******************************************
//  File Name:      UIViewController+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/8/15 2:16 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

public extension UIViewController {
    var navBarBottom: CGFloat {
        guard let navBar = navigationController?.navigationBar else {
            return 0
        }
        return navBar.bounds.height + UIApplication.statusBarHeight
    }

    var statusHeight: CGFloat { return UIApplication.statusBarHeight }

    var tabBarSizeH: CGFloat {
        tabBarController?.tabBar.sizeH ?? 0
    }

    static func currentVc() -> UIViewController? {
        var vc = UIApplication.keyWindow?.rootViewController
        while let presentVc = vc?.presentedViewController {
            vc = presentVc
        }
        return vc
    }

    static func xibVc(bundle: Bundle? = nil) -> Self {
        let name = String(className())
        return self.init(nibName: name, bundle: bundle)
    }
}
