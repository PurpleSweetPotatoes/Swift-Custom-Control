// *******************************************
//  File Name:      BQProxyView.swift       
//  Author:         MrBai
//  Created Date:   2022/5/11 23:06
//    
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit

public class BQProxyView: UIView {
    
    public weak var proxyGestureView: UIView?
    public weak var proxyHitView: UIView?

    public override var superview: UIView? {
        if let proxyView = proxyGestureView {
            return proxyView
        }
        return super.superview
    }
    
    // MARK: - *** Public method

    override public func removeFromSuperview() {
        proxyGestureView = nil
        super.removeFromSuperview()
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let responseV = super.hitTest(point, with: event)
        if let hitView = proxyHitView {
            let hitPoint = convert(point, to: hitView)
            if let proxyResponseV = hitView.hitTest(hitPoint, with: event), proxyResponseV != hitView {
                return proxyResponseV
            }
        }
        return responseV
    }
}
