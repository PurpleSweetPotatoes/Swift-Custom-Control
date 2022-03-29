// *******************************************
//  File Name:      UIScreen+Custom.swift
//  Author:         MrBai
//  Created Date:   2021/7/30 3:12 PM
//
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import UIKit

public extension UIScreen {
    static var width: CGFloat { return main.bounds.width }

    static var height: CGFloat { return main.bounds.height }
}
