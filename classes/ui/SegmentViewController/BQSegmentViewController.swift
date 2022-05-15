//
//
//  BQSegmentScrollerViewController.swift
//  RxSwiftDemo
//
//  Created by Bai, Payne on 2022/5/9.
//  Copyright © 2022 ___ORGANIZATIONNAME___ All rights reserved
//
    
import UIKit

public protocol SegmentContentView {
    var scrollView: UIScrollView? { get }
    var contentView: UIView { get }
}

open class BQSegmentViewController: UIViewController {
    // MARK: - *** Ivars

    private let scrollContext = ScrollingSwitchContext()
    private lazy var scrollView = createScrollView()
    public private(set) lazy var headerView = createHeaderView()
    public private(set) lazy var segmentView = createSegmentView()
    private lazy var contentView = createContentScrollView()
    open var contentSubViews: [SegmentContentView] {
        return []
    }
    
    private var externalChange: Bool = false
    open private(set) var currentIndex: Int = 0 {
        didSet {
            if oldValue != currentIndex, currentIndex < contentSubViews.count {
                currentIndexChange()
            } else {
                currentIndex = oldValue
            }
        }
    }
    
    public var navBarTransparent: Bool {
        return true
    }
    
    open var headerViewHeight: CGFloat {
        return 0
    }
    
    open var fixedSegmentHeight: CGFloat {
        return 0
    }
    
    open var segmentViewHeight: CGFloat {
        return 50
    }
    
    open var contentViewHeight: CGFloat {
        return UIScreen.height - segmentView.sizeH - navBarBottom
    }
    
    // MARK: - *** Public method

    public func resetCurrentIndex(_ index: Int) {
        externalChange = true
        currentIndex = index
        externalChange = false
    }

    open func currentIndexDidChange() {}
    
    open func parentScrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }

    // MARK: - *** Life cycle

    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        configUI()
    }

    // MARK: - *** NetWork method

    // MARK: - *** Event Action
    
    // MARK: - *** Delegate

    // MARK: - *** Instance method
    
    private func configChildScrollView(_ scrollView: UIScrollView?) {
        headerView.proxyGestureView = scrollView
        segmentView.proxyGestureView = scrollView
        scrollContext.childScrollView = scrollView
    }
    
    private func currentIndexChange() {
        if externalChange {
            contentView.setContentOffset(CGPoint(x: CGFloat(currentIndex) * contentView.sizeW, y: 0), animated: true)
        }
        let scrollView = contentSubViews[currentIndex].scrollView
        scrollContext.childScrollView = scrollView
        headerView.proxyGestureView = scrollView
        segmentView.proxyGestureView = scrollView
        currentIndexDidChange()
    }

    // MARK: - *** UI method
    
    private func configUI() {
        scrollView.addSubview(headerView)
        scrollView.addSubview(segmentView)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: scrollView.sizeW, height: contentView.bottom)
        
        scrollContext.scrollingSwitchHeight = fixedSegmentHeight
        scrollContext.parentScrollView = scrollView
        
        for (index, subView) in contentSubViews.enumerated() {
            contentView.addSubview(subView.contentView)
            subView.contentView.frame = CGRect(x: CGFloat(index) * contentView.sizeW, y: 0, width: contentView.sizeW, height: contentView.sizeH)
        }
        
        contentView.contentSize = CGSize(width: CGFloat(contentSubViews.count) * contentView.sizeW, height: contentView.sizeH)
        
        configChildScrollView(contentSubViews[0].scrollView)
    }
    
    // MARK: - *** Ivar Getter
    
    private func createScrollView() -> BQScrollView {
        let scrollV = BQScrollView(frame: CGRect(x: 0, y: 0, width: view.sizeW, height: view.sizeH))
        scrollV.allowGestrueThrough = headerViewHeight > 0
        scrollV.scrollContext = scrollContext
        scrollV.delegate = self
        
        if navBarTransparent {
            scrollV.noAdjustInsets(vc: self)
        }
        return scrollV
    }
    
    private func createHeaderView() -> BQProxyView {
        let headerV = BQProxyView(frame: CGRect(x: 0, y: 0, width: view.sizeW, height: headerViewHeight))
        headerV.backgroundColor = .clear
        return headerV
    }
    
    private func createSegmentView() -> BQProxyView {
        let segmentV = BQProxyView(frame: CGRect(x: 0, y: headerViewHeight, width: view.sizeW, height: segmentViewHeight))
        segmentV.backgroundColor = .clear
        return segmentV
    }
    
    private func createContentScrollView() -> BQScrollView {
        let scrollV = BQScrollView(frame: CGRect(x: 0, y: segmentView.bottom, width: view.sizeW, height: contentViewHeight))
        scrollV.showsHorizontalScrollIndicator = false
        scrollV.bounces = false
        scrollV.isPagingEnabled = true
        scrollV.delegate = self
        return scrollV
    }
}

extension BQSegmentViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            if scrollContext.parentCanScroll {
                contentSubViews.forEach { contentView in
                    contentView.scrollView?.contentOffset.y = 0
                }
            }
            parentScrollViewDidScroll(scrollView)
            return
        }
        
        if externalChange { return }
        
        let item = Int(scrollView.contentOffset.x / scrollView.sizeW)
        if item != currentIndex {
            currentIndex = item
        }
    }
}
