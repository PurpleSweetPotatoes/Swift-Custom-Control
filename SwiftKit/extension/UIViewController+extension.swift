//
//  UIViewController+extension.swift
//  swift4.2Demo
//
//  Created by baiqiang on 2018/10/8.
//  Copyright © 2018年 baiqiang. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var navBarBottom: CGFloat {
        get {
            return self.navigationController?.navigationBar.bottom ?? 0
        }
    }
    
    var tabBarSizeH: CGFloat {
        get {
            return self.tabBarController?.tabBar.sizeH ?? 0
        }
    }
    
    class func currentVc() -> UIViewController? {
        var vc = UIApplication.shared.keyWindow?.rootViewController
        while let presentVc = vc?.presentedViewController {
            vc = presentVc
        }
        return vc
    }
    
}
