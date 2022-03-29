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
            return nvc.navigationBar.bounds.height + AppInfo.statusHeight
        } else {
            return 0
        }
    }

    var statusHeight: CGFloat { return AppInfo.statusHeight }

    var tabBarSizeH: CGFloat {
        return tabBarController?.tabBar.sizeH ?? 0
    }

    static func currentVc() -> UIViewController? {
        var vc = UIApplication.shared.keyWindow?.rootViewController
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
