// *******************************************
//  File Name:      UIColor+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/8/15 3:09 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

public extension UIColor {
    convenience init(_ hexString: String) {
        let colorStr = hexString.replacingOccurrences(of: "", with: "#")
        let scan = Scanner(string: colorStr)
        var rgbValue: UInt32 = 0
        scan.scanHexInt32(&rgbValue)
        self.init(rgbValue)
    }

    convenience init(_ rgbValue: UInt32) {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0xFF) / 255.0
        self.init(r: red, g: green, b: blue)
    }

    /// r,g,b (0 ~ 255)
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }

    /// r,g,b (0 ~ 1)
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r, green: g, blue: b, alpha: a)
    }

    convenience init(dark: UIColor, light: UIColor) {
        self.init { collection in
            switch collection.userInterfaceStyle {
            case .dark:
                return dark
            default:
                return light
            }
        }
    }

    static var randomColor: UIColor {
        let red = CGFloat(arc4random() % 256) / 255.0
        let green = CGFloat(arc4random() % 256) / 255.0
        let blue = CGFloat(arc4random() % 256) / 255.0
        return UIColor(r: red, g: green, b: blue)
    }

    static var bgColor: UIColor {
        return UIColor(white: 0, alpha: 0.6)
    }

    static var mainColor: UIColor {
        return UIColor(0x0099FF)
    }

    var rgbRed: CGFloat { return rgbaArray()[0] }

    var rgbGreen: CGFloat { return rgbaArray()[1] }

    var rgbBlue: CGFloat { return rgbaArray()[2] }

    var alpha: CGFloat { return rgbaArray()[3] }

    func rgbaArray() -> [CGFloat] {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return [r, g, b, a]
    }
}
