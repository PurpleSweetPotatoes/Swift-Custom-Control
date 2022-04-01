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
    static func lineLayer(frame: CGRect, color: UIColor = .groupTableViewBackground) -> CAShapeLayer {
        let line = CAShapeLayer()
        line.frame = frame
        line.backgroundColor = color.cgColor
        return line
    }
    
    static func dashLayer(frame: CGRect, color: UIColor = .groupTableViewBackground, dashPattern: [NSNumber] = [5, 5]) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = frame
        shapeLayer.lineDashPattern = dashPattern
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = shapeLayer.sizeH
                
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: shapeLayer.sizeW, y: 0))
        shapeLayer.path = path
        return shapeLayer
    }

    static func gradientLayer(frame: CGRect, start: GradientPostion = .leftTop, end: GradientPostion = .leftBottom, colors: [CGColor], locations: [NSNumber]? = nil) -> CAGradientLayer {
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
    
    @discardableResult
    func origin(_ origin: CGPoint) -> Self {
        self.origin = origin
        return self;
    }

    var top: CGFloat {
        get { return frame.origin.y }
        set { frame.origin = CGPoint(x: frame.origin.x, y: newValue) }
    }
    
    @discardableResult
    func top(_ top: CGFloat) -> Self {
        self.top = top
        return self;
    }

    var left: CGFloat {
        get { return frame.origin.x }
        set { frame.origin = CGPoint(x: newValue, y: frame.origin.y) }
    }

    @discardableResult
    func left(_ left: CGFloat) -> Self {
        self.left = left
        return self;
    }
    
    var bottom: CGFloat {
        get { return frame.origin.y + frame.height }
        set { top = newValue - frame.height }
    }
    
    @discardableResult
    func bottom(_ bottom: CGFloat) -> Self {
        self.bottom = bottom
        return self;
    }

    var right: CGFloat {
        get { return frame.origin.x + frame.width }
        set { left = newValue - frame.width }
    }
    
    @discardableResult
    func right(_ right: CGFloat) -> Self {
        self.right = right
        return self;
    }

    var size: CGSize {
        get { return bounds.size }
        set { bounds.size = newValue }
    }
    
    @discardableResult
    func size(_ size: CGSize) -> Self {
        self.size = size
        return self;
    }

    var sizeW: CGFloat {
        get { return frame.width }
        set { frame.size = CGSize(width: newValue, height: frame.height) }
    }
    
    @discardableResult
    func sizeW(_ sizeW: CGFloat) -> Self {
        self.sizeW = sizeW
        return self;
    }

    var sizeH: CGFloat {
        get { return frame.height }
        set { frame.size = CGSize(width: frame.width, height: newValue) }
    }
    
    @discardableResult
    func sizeH(_ sizeH: CGFloat) -> Self {
        self.sizeH = sizeH
        return self;
    }
}
