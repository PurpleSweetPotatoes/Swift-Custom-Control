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
        contentInsetAdjustmentBehavior = .never
    }
    
    var captureLongImage: UIImage? {
        var image: UIImage?
        
        let savedContentOffset = contentOffset
        let savedFrame = frame
        contentOffset = .zero
        frame = CGRect(origin: .zero, size: contentSize)
        
        UIGraphicsBeginImageContextWithOptions(contentSize, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        
        contentOffset = savedContentOffset
        frame = savedFrame
        
        return image
    }
}
