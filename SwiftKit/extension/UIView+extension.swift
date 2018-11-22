//
//  UIView+extension.swift
//  swift4.2Demo
//
//  Created by baiqiang on 2018/10/6.
//  Copyright © 2018年 baiqiang. All rights reserved.
//

import UIKit

private let KBgRoundLayer = "KBgRoundLayer"

//MARK:- ***** 视图位置调整 *****
extension UIView {
    
    //MARK:- ***** publice var and function *****
    var top : CGFloat {
        get {
            return self.frame.origin.y
        }
        set(top) {
            self.frame.origin = CGPoint(x: self.frame.origin.x, y: top)
        }
    }
    
    var left : CGFloat {
        get {
            return self.frame.origin.x
        }
        set(left) {
            self.frame.origin = CGPoint(x: left, y: self.frame.origin.y)
        }
    }
    
    var bottom : CGFloat {
        get {
            return self.frame.maxY
        }
        set(bottom) {
            self.top = bottom - self.sizeH
        }
    }
    
    var right : CGFloat {
        get {
            return self.frame.maxX
        }
        set(right) {
            self.left = right - self.sizeW
        }
    }
    
    var sizeW : CGFloat {
        get {
            return self.bounds.size.width
        }
        set(sizeW) {
            self.frame.size = CGSize(width: sizeW, height: self.frame.height)
        }
    }
    
    var sizeH : CGFloat {
        get {
            return self.bounds.size.height
        }
        set(height) {
            self.frame.size = CGSize(width: self.sizeW, height: height)
        }
    }
    
    var size: CGSize {
        get {
            return self.bounds.size
        }
        set(size) {
            self.frame.size = size
        }
    }
    
    var origin : CGPoint {
        get {
            return self.frame.origin;
        }
        set(origin) {
            self.frame.origin = origin
        }
    }
    
    func setCorner(readius:CGFloat) {
        self.layer.allowsEdgeAntialiasing = true
        self.layer.cornerRadius = readius
        self.clipsToBounds = true
    }
    
    func toRound() {
        self.setCorner(readius: self.bounds.size.width * 0.5)
    }
    
    func setBordColor(color:UIColor) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1.0
    }
    
    func addTapGes(action:@escaping (_ view: UIView) -> ()) {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureAction))
        self.isUserInteractionEnabled = true
        self.action = action
        self.addGestureRecognizer(gesture)
    }
    
    func setRoundCorners( readius:CGFloat, corners:UIRectCorner) {
        
        var bgColor = self.backgroundColor
        self.backgroundColor = .clear
        
        if let subLayers = self.layer.sublayers {
            for subLayer in subLayers {
                if subLayer.name == KBgRoundLayer {
                    bgColor = UIColor(cgColor: (subLayer as! CAShapeLayer).fillColor!)
                    subLayer.removeFromSuperlayer()
                    break
                }
            }
        }
        
        let beizPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: readius, height: readius))
        let roundPath = CAShapeLayer()
        roundPath.frame = self.bounds
        roundPath.name = KBgRoundLayer
        roundPath.path = beizPath.cgPath
        roundPath.fillColor = bgColor?.cgColor
        
        self.layer.insertSublayer(roundPath, at: 0)
    }
    
    //MARK:- ***** Override function *****
    
    //MARK:- ***** Private tapGesture *****
    typealias addBlock = (_ imageView: UIView) -> Void
    
    private struct AssociatedKeys {
        static var actionKey = "actionBlock"
    }
    
    private var action: addBlock? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.actionKey) as? addBlock
        }
        set (newValue){
            objc_setAssociatedObject(self, &AssociatedKeys.actionKey, newValue!, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
        
        guard let actionBlock = self.action else {
            return
        }
        
        if sender.state == .ended {
            actionBlock(self)
        }
    }
    
    
}
