// *******************************************
//  File Name:      UINavigationBar+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2021/6/2 11:55 AM
//
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import UIKit

public extension UINavigationBar {
    // MARK: - public method

    func lt_setBackgroundColor(color: UIColor) {
        if overlayView == nil {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + UIApplication.statusBarHeight))
            view.isUserInteractionEnabled = false
            view.autoresizingMask = .flexibleWidth
            setBackgroundImage(UIImage(), for: .default)
            shadowImage = UIImage()
            subviews.first?.insertSubview(view, at: 0)
            overlayView = view
        }

        if let view = overlayView, view.superview == nil {
            subviews.first?.insertSubview(view, at: 0)
        }

        overlayView?.backgroundColor = color
    }

    func lt_setElementsAlpha(alpha: CGFloat) {
        subviews.first?.alpha = alpha
    }

    func lt_setTranslationY(translationY: CGFloat) {
        transform = CGAffineTransform(translationX: 0, y: translationY)
    }

    func lt_reset() {
        lt_setElementsAlpha(alpha: 1)
        setBackgroundImage(nil, for: .default)
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = nil
        overlayView?.removeFromSuperview()
        overlayView = nil
    }

    // MARK: - privati var

    private enum AssociatedKeys {
        static var overlayKey: Void?
    }

    private var overlayView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.overlayKey) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.overlayKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
