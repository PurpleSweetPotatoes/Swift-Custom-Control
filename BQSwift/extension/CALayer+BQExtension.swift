// *******************************************
//  File Name:      CALayer+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/8/15 9:08 AM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

public enum GradientPostion: Int {
    case leftTop, rightTop, leftBottom, rightBottom
    func convenPoint() -> CGPoint {
        switch self {
        case .leftTop:
            return CGPoint.zero
        case .rightTop:
            return CGPoint(x: 1, y: 0)
        case .leftBottom:
            return CGPoint(x: 0, y: 1)
        case .rightBottom:
            return CGPoint(x: 1, y: 1)
        }
    }
}

public extension CALayer {
    class func lineLayer(frame: CGRect, color: UIColor = UIColor.groupTableViewBackground) -> CAShapeLayer {
        let line = CAShapeLayer()
        line.frame = frame
        line.backgroundColor = color.cgColor
        return line
    }

    class func gradientLayer(frame: CGRect, start: GradientPostion = .leftTop, end: GradientPostion = .leftBottom, colors: [CGColor], locations: [NSNumber]? = nil) -> CAGradientLayer {
        let gradLayer = CAGradientLayer()
        gradLayer.frame = frame
        gradLayer.colors = colors
        gradLayer.locations = locations
        gradLayer.startPoint = start.convenPoint()
        gradLayer.endPoint = end.convenPoint()

        return gradLayer
    }

    var origin: CGPoint {
        get { return frame.origin }
        set { frame.origin = newValue }
    }

    var top: CGFloat {
        get { return frame.origin.y }
        set { frame.origin = CGPoint(x: frame.origin.x, y: newValue) }
    }

    var left: CGFloat {
        get { return frame.origin.x }
        set { frame.origin = CGPoint(x: newValue, y: frame.origin.y) }
    }

    var bottom: CGFloat {
        get { return frame.origin.y + frame.height }
        set { top = newValue - frame.height }
    }

    var right: CGFloat {
        get { return frame.origin.x + frame.width }
        set { left = newValue - frame.width }
    }

    var size: CGSize {
        get { return bounds.size }
        set { bounds.size = newValue }
    }

    var sizeW: CGFloat {
        get { return frame.width }
        set { frame.size = CGSize(width: newValue, height: frame.height) }
    }

    var sizeH: CGFloat {
        get { return frame.height }
        set { frame.size = CGSize(width: frame.width, height: newValue) }
    }
}
