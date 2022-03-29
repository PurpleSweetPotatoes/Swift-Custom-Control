// *******************************************
//  File Name:      UIView+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/8/15 2:18 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

extension UIView {
    var origin: CGPoint {
        get { return frame.origin }
        set { frame.origin = newValue }
    }
    
    @discardableResult
    func origin(_ origin: CGPoint) -> Self {
        self.origin = origin
        return self
    }
    
    
    var top: CGFloat {
        get { return frame.origin.y }
        set { frame.origin = CGPoint(x: frame.origin.x, y: newValue) }
    }
    
    @discardableResult
    func top(_ top: CGFloat) -> Self {
        self.top = top
        return self
    }
    
    var left: CGFloat {
        get { return frame.origin.x }
        set { frame.origin = CGPoint(x: newValue, y: frame.origin.y) }
    }
    
    @discardableResult
    func left(_ left: CGFloat) -> Self {
        self.left = left
        return self
    }

    var bottom: CGFloat {
        get { return frame.origin.y + frame.height }
        set { top = newValue - frame.height }
    }
    
    @discardableResult
    func bottom(_ bottom: CGFloat) -> Self {
        self.bottom = bottom
        return self
    }

    var right: CGFloat {
        get { return frame.origin.x + frame.width }
        set { left = newValue - frame.width }
    }
    
    @discardableResult
    func right(_ right: CGFloat) -> Self {
        self.right = right
        return self
    }

    var size: CGSize {
        get { return bounds.size }
        set { bounds.size = newValue }
    }
    
    @discardableResult
    func size(_ size: CGSize) -> Self {
        self.size = size
        return self
    }

    var sizeW: CGFloat {
        get { return frame.width }
        set { frame.size = CGSize(width: newValue, height: frame.height) }
    }
    
    @discardableResult
    func sizeW(_ sizeW: CGFloat) -> Self {
        self.sizeW = sizeW
        return self
    }

    var sizeH: CGFloat {
        get { return frame.height }
        set { frame.size = CGSize(width: frame.width, height: newValue) }
    }
    
    @discardableResult
    func sizeH(_ sizeH: CGFloat) -> Self {
        self.sizeH = sizeH
        return self
    }
    
    func cneter(_ point: CGPoint) -> Self {
        center = point
        return self
    }

    @discardableResult
    func toRound() -> Self {
        return corner(frame.height * 0.5)
    }

    @discardableResult
    func corner(_ readius: CGFloat) -> Self {
        layer.allowsEdgeAntialiasing = true
        layer.cornerRadius = readius
        clipsToBounds = true
        return self
    }

    @discardableResult
    func backgroundColor(_ color: UIColor) -> Self {
        backgroundColor = color
        return self
    }

    @discardableResult
    func setBordColor(color: UIColor, width: CGFloat = 1.0) -> Self{
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        return self
    }
    
    static func xibView(name: String? = nil) -> Self? {
        var clsName = ""
        if let cn = name {
            clsName = cn
        } else {
            clsName = className()
        }
        return Bundle.main.loadNibNamed(clsName, owner: nil, options: nil)?.last as? Self
    }

    func snapshoot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            let opImg = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return opImg
        }
        return nil
    }

    @discardableResult
    func addTapGes(action: @escaping (_ view: UIView) -> Void) -> Self {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(myTapGestureAction))
        isUserInteractionEnabled = true
        self.action = action
        addGestureRecognizer(gesture)
        return self
    }

    // MARK: - ***** Private tapGesture *****

    typealias addBlock = (_ view: UIView) -> Void

    private enum AssociatedKeys {
        static var actionKey: Void?
    }

    private var action: addBlock? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.actionKey) as? addBlock
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.actionKey, newValue!, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    @objc private func myTapGestureAction(sender: UITapGestureRecognizer) {
        guard let actionBlock = action else {
            return
        }

        if sender.state == .ended {
            actionBlock(self)
        }
    }
}
