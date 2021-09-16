// *******************************************
//  File Name:      UIViewController+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/8/15 2:16 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

extension UIViewController {
    var navBarBottom: CGFloat {
        if let nvc = navigationController {
            return nvc.navigationBar.bounds.height + UIApplication.shared.statusBarFrame.height
        } else {
            return 0
        }
    }

    var statusHeight: CGFloat { return UIApplication.shared.statusBarFrame.height }

    var tabBarSizeH: CGFloat {
        return tabBarController?.tabBar.sizeH ?? 0
    }

    class func currentVc() -> UIViewController? {
        var vc = UIApplication.shared.keyWindow?.rootViewController
        while let presentVc = vc?.presentedViewController {
            vc = presentVc
        }
        return vc
    }
}
