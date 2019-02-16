//
//  UINavigationBar+extension.swift
//  GuoWei
//
//  Created by baiqiang on 2019/2/16.
//  Copyright © 2019年 baiqiang. All rights reserved.
//

import UIKit



extension UINavigationBar {
    
    
    public func lt_setBackgroundColor(color:UIColor) {
        if self.overlay == nil {
            self.setBackgroundImage(UIImage(), for: .default)
            self.shadowImage = UIImage()
            self.overlay = UIView(frame: CGRect(x: 0, y: 0, width: self.sizeW, height: self.bottom))
            self.overlay?.isUserInteractionEnabled = false
            self.overlay?.autoresizingMask = .flexibleWidth
            self.subviews.first?.insertSubview(self.overlay!, at: 0)
        }
        self.overlay?.backgroundColor = color
    }
    
    
    public func lt_setTranslationY(offsetY:CGFloat) {
        self.transform = CGAffineTransform(translationX: 0, y: offsetY)
    }
    
    public func lt_setElementsAlpha(alpha:CGFloat) {
        
        self.changeViewAlpha(alpha: alpha, key: "_leftViews")
        self.changeViewAlpha(alpha: alpha, key: "_rightViews")
        if let titleView = self.value(forKey: "_titleView") as? UIView {
            titleView.alpha = alpha
        }
        for subView in self.subviews {
            if subView.isKind(of:NSClassFromString("UINavigationItemView")!) || subView.isKind(of:NSClassFromString("_UINavigationBarBackIndicatorView")!){
                subView.alpha = alpha
            }
        }
    }
    
    public func lt_reset() {
        self.setBackgroundImage(nil, for: .default)
        self.shadowImage = nil
        self.overlay?.removeFromSuperview()
        self.overlay = nil
    }
    
    private func changeViewAlpha(alpha:CGFloat, key:String) {
        if let subViews = self.value(forKey: key) as? [UIView] {
            for view in subViews {
                view.alpha = alpha
            }
        }
    }
    
    private struct AssociatedKeys {
        static var overlayKey = ""
    }
    
    private var overlay: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.overlayKey) as? UIView
        }
        set (newValue){
            objc_setAssociatedObject(self, &AssociatedKeys.overlayKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

