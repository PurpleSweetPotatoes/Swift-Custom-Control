//
//  UIApplication+Extension.swift
//  Pods
//  
//  Created by Bai, Payne on 2023/3/12.
//  Copyright © 2023 Garmin All rights reserved
//  

import UIKit

public extension UIApplication {
    static var width: CGFloat {
        UIApplication.shared
            .connectedScenes
            .first(where: { $0 is UIWindowScene })
            .flatMap { $0 as? UIWindowScene }?.windows
            .first(where: \.isKeyWindow)?.screen.bounds.width ?? 0
    }
}
