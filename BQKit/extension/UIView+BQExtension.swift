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
    
    func toRound() {
        self.setCorner(readius: self.frame.height * 0.5)
    }
    
    func setCorner(readius:CGFloat) {
        self.layer.allowsEdgeAntialiasing = true
        self.layer.cornerRadius = readius
        self.clipsToBounds = true
    }
    
    func setBordColor(color:UIColor, width: CGFloat = 1.0) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    func addTapGes(action:@escaping (_ view: UIView) -> ()) {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureAction))
        self.isUserInteractionEnabled = true
        self.action = action
        self.addGestureRecognizer(gesture)
    }
    
    //MARK:- ***** Private tapGesture *****
    typealias addBlock = (_ view: UIView) -> Void
    
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
