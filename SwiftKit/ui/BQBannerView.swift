//
//  BQBannerView.swift
//  BQTabBarTest
//
//  Created by MrBai on 2017/7/31.
//  Copyright © 2017年 MrBai. All rights reserved.
//

import UIKit

class BQBannerView: UIView, UIScrollViewDelegate {
    //MARK: - ***** Ivars *****
    private var urlArr: [String] = []
    private var clickHandler: ((Int)->())?
    private var scrollView = UIScrollView()
    private var pageCtlr = UIPageControl()
    private var imgViews:[UIImageView] = []
    private var currentIndex: Int = 0
    private var time:TimeInterval = 0
    private weak var timer: Timer?
    //MARK: - ***** initialize Method *****
    convenience init(frame: CGRect , time:TimeInterval = 2, urlArr:[String], clickHandler:@escaping (Int)->()) {
        self.init(frame: frame)
        self.time = time
        self.reloadUrl(urlArr: urlArr)
        self.clickHandler = clickHandler
    }
    override init(frame: CGRect) {
        clickHandler = nil
        timer = nil
        super.init(frame: frame)
        self.initUI()
        self.addTapGes {[weak self] (view) in
            self?.clickHandler?(self?.currentIndex ?? 0)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
    //MARK: - ***** Instance Method *****
    private func initUI() {
        let width = self.sizeW
        let height = self.sizeH
        self.backgroundColor = UIColor.cyan
        self.scrollView.frame = self.bounds
        self.scrollView.contentSize = CGSize(width: width * 3, height: height)
        self.scrollView.isPagingEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.bounces = false
        self.scrollView.delegate = self
        self.scrollView.contentOffset = CGPoint(x: width, y: 0)
        self.addSubview(self.scrollView)
        self.pageCtlr.frame = CGRect(x: 0, y: self.sizeH - 30, width: width, height: 30)
        self.addSubview(self.pageCtlr)
        for index in 0..<3 {
            let imgView = UIImageView(frame: self.scrollView.bounds)
            imgView.left = CGFloat(index) * imgView.sizeW
            self.imgViews.append(imgView)
            self.scrollView.addSubview(imgView)
        }
    }
    private func beginTimer() {
        self.imgChage()
        self.endTimer()
        self.timer = Timer.scheduledTimer(timeInterval: self.time, target: BQWeakProxy(target: self), selector: #selector(timerHandler(timer:)), userInfo: nil, repeats: true)
    }
    private func endTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    private func imgChage() {
        while self.currentIndex < 0 || self.currentIndex >= self.urlArr.count {
            self.currentIndex += self.urlArr.count
            self.currentIndex %= self.urlArr.count
        }
        self.pageCtlr.currentPage = self.currentIndex
        for index in -1...1 {
            var subIndex = self.currentIndex + index
            if subIndex < 0 {
                subIndex = self.urlArr.count - 1
            }else if subIndex == self.urlArr.count {
                subIndex = 0
            }
            self.imgViews[index + 1].setImage(urlStr: self.urlArr[subIndex])
        }
    }
    //MARK: - ***** LoadData Method *****
    public func reloadUrl(urlArr:[String]) {
        if urlArr.count <= 3 {
            return
        }
        self.urlArr = urlArr
        self.pageCtlr.numberOfPages = urlArr.count
        self.pageCtlr.currentPage = self.currentIndex
        self.beginTimer()
    }
    //MARK: - ***** respond event Method *****
    @objc private func timerHandler(timer:Timer) {
        self.currentIndex += 1
        self.scrollView.setContentOffset(CGPoint(x: self.scrollView.sizeW * 2, y: 0), animated: true)
    }
    //MARK: - ***** Protocol *****
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.endTimer()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var point:CGPoint = CGPoint.zero
        if targetContentOffset.pointee.x >= scrollView.sizeW * 1.5 {
            point = CGPoint(x: scrollView.sizeW * 2, y: 0)
            self.currentIndex += 1
        }else if targetContentOffset.pointee.x < scrollView.sizeW * 0.5{
            point = CGPoint(x: 0, y: 0)
            self.currentIndex -= 1
        }else {
            point = CGPoint(x: scrollView.sizeW, y: 0)
        }
        scrollView.setContentOffset(point, animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPoint(x: scrollView.sizeW, y: 0), animated: false)
        self.beginTimer()
    }

}
