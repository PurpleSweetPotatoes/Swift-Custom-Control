// *******************************************
//  File Name:      ScrollThouthContext.swift
//  Author:         MrBai
//  Created Date:   2022/5/11 23:30
//
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    
import UIKit

public class ScrollingSwitchContext {
    public var parentCanScroll = true
    public var scrollingSwitchHeight: CGFloat = 0
    public weak var parentScrollView: UIScrollView?
    private var childScrollVObserve: NSKeyValueObservation?
    public weak var childScrollView: UIScrollView? {
        didSet {
            childScrollVObserve?.invalidate()
            if let subScrollV = childScrollView {
                childScrollVObserve = subScrollV.observe(\.contentOffset, options: [.old, .new]) { [weak self] _, value in
                    if value.newValue != value.oldValue {
                        self?.updateScrollState()
                    }
                }
            } else {
                parentCanScroll = true
            }
        }
    }
    
    deinit {
        childScrollVObserve?.invalidate()
    }
    
    public func updateScrollState() {
        guard let superScrollView = parentScrollView, let subScrollView = childScrollView else { return }
        if parentCanScroll {
            subScrollView.contentOffset.y = 0
            if superScrollView.contentOffset.y >= scrollingSwitchHeight, subScrollView.isScrollEnabled {
                superScrollView.contentOffset.y = scrollingSwitchHeight
                parentCanScroll = false
            }
        } else {
            superScrollView.contentOffset.y = scrollingSwitchHeight
            if subScrollView.contentOffset.y <= 0 {
                subScrollView.contentOffset.y = 0
                parentCanScroll = true
            }
        }
        superScrollView.showsVerticalScrollIndicator = parentCanScroll
        subScrollView.showsVerticalScrollIndicator = !parentCanScroll
    }
}
