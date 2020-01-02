// *******************************************
//  File Name:      CALayer+BQExtension.swift       
//  Author:         MrBai
//  Created Date:   2019/8/15 9:08 AM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************
    

import UIKit

extension CALayer {
    
    public class func lineLayer(frame: CGRect, color: UIColor = UIColor.groupTableViewBackground) -> CAShapeLayer {
        let line = CAShapeLayer()
        line.frame = frame
        line.backgroundColor = color.cgColor
        return line
    }
    
    public var origin: CGPoint {
        get { return self.frame.origin }
        set { self.frame.origin = newValue }
    }
    
    public var top : CGFloat {
        get { return self.frame.origin.y }
        set { self.frame.origin = CGPoint(x: self.frame.origin.x, y: newValue) }
    }
    
    public var left : CGFloat {
        get { return self.frame.origin.x }
        set { self.frame.origin = CGPoint(x: newValue, y: self.frame.origin.y) }
    }
    
    public var bottom : CGFloat {
        get { return self.frame.origin.y + self.frame.height}
        set { self.top = newValue - self.frame.height }
    }
    
    public var right : CGFloat {
        get { return self.frame.origin.x  + self.frame.width}
        set { self.left = newValue - self.frame.width }
    }
    
    public var size: CGSize {
        get { return self.bounds.size }
        set { self.bounds.size = newValue }
    }
    
    public var sizeW : CGFloat {
        get { return self.frame.width}
        set { self.frame.size = CGSize(width: newValue, height: self.frame.height) }
    }
    
    public var sizeH : CGFloat {
        get { return self.frame.height}
        set { self.frame.size = CGSize(width: self.frame.width, height: newValue) }
    }
    
}
