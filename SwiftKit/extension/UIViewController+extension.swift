//
//  UIViewController+extension.swift
//  swift4.2Demo
//
//  Created by baiqiang on 2018/10/8.
//  Copyright © 2018年 baiqiang. All rights reserved.
//

import UIKit

extension UIViewController {
    
    class func currentVc() -> UIViewController? {
        var vc = UIApplication.shared.keyWindow?.rootViewController
        while let presentVc = vc?.presentedViewController {
            vc = presentVc
        }
        return vc
    }
    
}
