// *******************************************
//  File Name:      UINavigationBar+BQExtension.swift       
//  Author:         MrBai
//  Created Date:   2021/6/2 11:55 AM
//    
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit


extension UINavigationBar {
    // MARK: - public method
    public func lt_setBackgroundColor(color: UIColor) -> Void {
        if overlayView == nil {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height + UIApplication.shared.statusBarFrame.height))
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
    
    public func lt_setElementsAlpha(alpha: CGFloat) -> Void {
        subviews.first?.alpha = alpha
    }
    
    public func lt_setTranslationY(translationY: CGFloat) -> Void {
        transform = CGAffineTransform(translationX: 0, y: translationY)
    }
    
    public func lt_reset() -> Void {
        setBackgroundImage(nil, for: .default)
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = nil
        overlayView?.removeFromSuperview()
    }
    
    // MARK: - privati var
    
    private struct AssociatedKeys {
        static var overlayKey: Void?
    }
    
    private var overlayView: UIView? {
        get {
            
            return objc_getAssociatedObject(self, &AssociatedKeys.overlayKey) as? UIView
        }
        set (newValue){
            objc_setAssociatedObject(self, &AssociatedKeys.overlayKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
