//
//  BQRefreshView.swift
//  BQRefresh
//
//  Created by baiqiang on 2017/7/5.
//  Copyright © 2017年 baiqiang. All rights reserved.
//

import UIKit

enum RefreshStatus: Int {
    case idle //闲置
    case pull //拖拽
    case refreshing //刷新
    case willRefresh //即将刷新
    case noMoreData //无更多数据
}

enum ObserverName: String {
    case scrollerOffset = "contentOffset"
    case scrollerSize = "contentSize"
}

typealias CallBlock = ()->()

class BQRefreshView: UIView {

    //MARK: - ***** Ivars *****
    var origiOffsetY: CGFloat = 0
    public var scrollViewOriginalInset: UIEdgeInsets = .zero
    public var status: RefreshStatus = .idle
    public weak var scrollView: UIScrollView!
    public var refreshBlock: CallBlock!

    //MARK: - ***** public Method *****
    public class func refreshLab() -> UILabel {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textAlignment = .center
        return lab
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if !(newSuperview is UIScrollView) {
            return
        }
        self.removeObservers()
        self.width = newSuperview?.width ?? 0
        self.left = 0
        self.scrollView = newSuperview as! UIScrollView
        self.scrollViewOriginalInset = self.scrollView.contentInset
        self.addObservers()
    }
    //MARK: - ***** private Method *****

    private func addObservers() {
        let options: NSKeyValueObservingOptions = [.new, .old]
        self.scrollView.addObserver(self, forKeyPath: ObserverName.scrollerOffset.rawValue, options: options, context: nil)
        self.scrollView.addObserver(self, forKeyPath: ObserverName.scrollerSize.rawValue, options: options, context: nil)
    }
    private func removeObservers() {
        self.superview?.removeObserver(self, forKeyPath: ObserverName.scrollerOffset.rawValue)
        self.superview?.removeObserver(self, forKeyPath: ObserverName.scrollerSize.rawValue)

    }
    //MARK: - ***** respond event Method *****
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if !self.isUserInteractionEnabled {
            return
        }
        if self.isHidden {
            return
        }
        if let key = keyPath {
            let value = ObserverName(rawValue: key)!
            switch value {
            case .scrollerOffset:
                self.contentOffsetDidChange(change: change)
            case .scrollerSize:
                self.contentSizeDidChange(change: change)
            }
        }
    }
    
    func contentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?) {
        if self.status == .idle && !self.scrollView.isDragging {
            origiOffsetY = self.scrollView.contentOffset.y
            self.status = .pull
        }
    }

    func contentSizeDidChange(change: [NSKeyValueChangeKey : Any]?) {
        
    }
}
