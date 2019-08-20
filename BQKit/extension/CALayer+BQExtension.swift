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
    
    class func lineLayer(frame: CGRect, color: UIColor = UIColor.groupTableViewBackground) -> CAShapeLayer {
        let line = CAShapeLayer()
        line.frame = frame
        line.backgroundColor = color.cgColor
        return line
    }
    
    var top : CGFloat {
        get { return self.frame.origin.y }
        set { self.frame.origin = CGPoint(x: self.frame.origin.x, y: newValue) }
    }
    
    var left : CGFloat {
        get { return self.frame.origin.x }
        set { self.frame.origin = CGPoint(x: newValue, y: self.frame.origin.y) }
    }
    
    var bottom : CGFloat {
        get { return self.frame.origin.y + self.frame.height}
        set { self.top = newValue - self.frame.height }
    }
    
    var right : CGFloat {
        get { return self.frame.origin.x  + self.frame.width}
        set { self.left = newValue - self.frame.width }
    }
    
    var sizeW : CGFloat {
        get { return self.frame.width}
        set { self.frame.size = CGSize(width: newValue, height: self.frame.height) }
    }
    
    var sizeH : CGFloat {
        get { return self.frame.height}
        set { self.frame.size = CGSize(width: self.frame.width, height: newValue) }
    }
    
}
