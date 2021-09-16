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

    func toRound() {
        setCorner(readius: frame.height * 0.5)
    }

    func setCorner(readius: CGFloat) {
        layer.allowsEdgeAntialiasing = true
        layer.cornerRadius = readius
        clipsToBounds = true
    }

    func setBordColor(color: UIColor, width: CGFloat = 1.0) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
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

    func addTapGes(action: @escaping (_ view: UIView) -> Void) {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
        isUserInteractionEnabled = true
        self.action = action
        addGestureRecognizer(gesture)
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

    @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
        guard let actionBlock = action else {
            return
        }

        if sender.state == .ended {
            actionBlock(self)
        }
    }
}
