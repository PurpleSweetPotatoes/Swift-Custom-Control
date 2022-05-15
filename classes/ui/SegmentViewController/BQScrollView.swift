// *******************************************
//  File Name:      BQScrollView.swift       
//  Author:         MrBai
//  Created Date:   2022/5/11 23:23
//    
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit

public class BQScrollView: UIScrollView, UIGestureRecognizerDelegate {
    
    public var scrollContext: ScrollingSwitchContext?
    public var allowGestrueThrough = false
        
    public override var contentOffset: CGPoint {
        didSet {
            if contentOffset != oldValue {            
                scrollContext?.updateScrollState()
            }
        }
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view is BQScrollView {
            return false
        }
        return allowGestrueThrough
    }
}
