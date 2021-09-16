// *******************************************
//  File Name:      UIScrollView+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2021/6/4 11:57 AM
//
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import UIKit

public extension UIScrollView {
    func noAdjustInsets(vc: UIViewController) {
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            vc.automaticallyAdjustsScrollViewInsets = false
        }
    }
}
