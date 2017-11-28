//
//  UIColor+extension.swift
//  HJLBusiness
//
//  Created by MrBai on 2017/5/18.
//  Copyright © 2017年 baiqiang. All rights reserved.
//

import Foundation
import UIKit

private let main_color = UIColor("308ee3")
private let text_color = UIColor("444444")
private let line_color = UIColor("f7f7f7")

extension UIColor {

    class var randomColor: UIColor {
        get {
            let red = CGFloat(arc4random() % 256) / 255.0;
            let green = CGFloat(arc4random() % 256) / 255.0;
            let blue = CGFloat(arc4random() % 256) / 255.0;
            return UIColor(r: red, g: green, b: blue);
        }
    }
    
    class var mainColor: UIColor {
        get {
            return main_color
        }
    }
    
    class var textColor: UIColor {
        get {
            return text_color
        }
    }
    
    class var lineColor: UIColor {
        get {
            return line_color
        }
    }
    
    var rgbRed: CGFloat {
        get {
            return self.rgbaArray()[0]
        }
    }
    
    var rgbGreen: CGFloat {
        get {
            return self.rgbaArray()[1]
        }
    }
    
    var rgbBlue: CGFloat {
        get {
            return self.rgbaArray()[2]
        }
    }
    
    var alpha: CGFloat {
        get {
            return self.rgbaArray()[3]
        }
    }
    
    public func rgbaArray() -> Array<CGFloat> {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return [r,g,b,a]
    }
    
    public convenience init(_ hexString:String) {
        let colorStr = hexString.replacingOccurrences(of: "", with: "#")
        let scan = Scanner(string: colorStr)
        var rgbValue:UInt32 = 0;
        scan.scanHexInt32(&rgbValue)
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0;
        let green = CGFloat((rgbValue & 0xFF00) >> 8) / 255.0;
        let blue = CGFloat(rgbValue & 0xFF) / 255.0;
        self.init(r: red, g: green, b: blue)
    }
    
    /// r,g,b (0 ~ 1)
    public convenience init(r:CGFloat, g:CGFloat, b:CGFloat) {
        self.init(red: r , green: g , blue: b , alpha: 1)
    }
}
