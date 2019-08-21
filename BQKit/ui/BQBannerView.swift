// *******************************************
//  File Name:      BQBannerView.swift       
//  Author:         MrBai
//  Created Date:   2019/8/20 11:00 AM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************
    

import UIKit

protocol BQBannerViewDelegate {
    
    func numberOfBannerItems(bannerView: BQBannerView) -> NSInteger
    func prepareDisView(bannerView: BQBannerView, imgV: UIImageView, item: NSInteger)

    func didClickDisView(bannerView: BQBannerView, imgV: UIImageView, item: NSInteger)
    func didScrollToDisView(bannerView: BQBannerView, imgV: UIImageView, item: NSInteger)
}


class BQBannerView: UIView {

    // MARK: - var
    var delegate: BQBannerViewDelegate?
    var placeHolderImg: UIImage?
    var autoShowTime: TimeInterval = 0
    var showPageCtrl: Bool = true {
        didSet {
            _pageCtlr.isHidden = !showPageCtrl
        }
    }
    
    private var _imgVList = [UIImageView]()
    private var _index: Int = 0
    private var _scrollView = UIScrollView()
    private var _pageCtlr = UIPageControl()
    private var _timer: Timer?
    
    
    deinit {
        self.clearTimer()
    }
    
    // MARK: - creat

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - public method
    func reloadData() {
        _index = 0
        if showPageCtrl {
            _pageCtlr.currentPage = _index
            _pageCtlr.numberOfPages = delegate?.numberOfBannerItems(bannerView: self) ?? 0
            let size = _pageCtlr.size(forNumberOfPages: _pageCtlr.numberOfPages)
            _pageCtlr.frame = CGRect(x: (self.sizeW - size.width) * 0.5, y: self.sizeH - size.height, width: size.width, height: size.height)
        }
        self.startTimer()
    }
    
    // MARK: - private method
    private func reloadImgsInfo() {
        if let delegate = self.delegate {
            let maxNum = delegate.numberOfBannerItems(bannerView: self)
            _scrollView.isUserInteractionEnabled = maxNum > 1
            
            for (num, imgV) in _imgVList.enumerated() {
                let currentIndex = (_index - 1 + num + maxNum) % maxNum
                delegate.prepareDisView(bannerView: self, imgV: imgV, item: currentIndex)
            }
            _index = (_index + maxNum) % maxNum
            _pageCtlr.currentPage = _index
            delegate.didScrollToDisView(bannerView: self, imgV: _imgVList[1], item: _index)
        } else {
            for imgV in _imgVList {
                imgV.image = self.placeHolderImg
            }
            _scrollView.isUserInteractionEnabled = false
        }
    }
    
    private func startTimer() {
        if self.autoShowTime != 0 {
            if _timer == nil {            
                _timer = Timer.scheduledTimer(timeInterval: self.autoShowTime, target: BQWeakProxy(target: self), selector: #selector(timeDidChange(timer:)), userInfo: nil, repeats: true)
                RunLoop.current.add(_timer!, forMode: .common)
            }
        } else {
            self.clearTimer()
        }
        self.reloadImgsInfo()
    }
    
    private func clearTimer() {
        _timer?.invalidate()
        _timer = nil
    }
    
    // MARK: - Event method
    
    @objc private func timeDidChange(timer: Timer) {
        _index += 1
        _scrollView.setContentOffset(CGPoint(x: self.sizeW * 2, y: 0), animated: true)
    }
    
    @objc private func bannerTapGesturAction(tap: UITapGestureRecognizer) {
        print("点击事件")
        if tap.state == .ended {
            self.delegate?.didClickDisView(bannerView: self, imgV: _imgVList[1], item: _index)
        }
    }
    
    // MARK: - UI method
    func configUI() {
        
        self.configScrollView()
        self.configImgViews()
        self.configCtrlView()
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.bannerTapGesturAction(tap:)))
        self.addGestureRecognizer(tap)
    }
    
    private func configScrollView() {
        _scrollView.frame = self.bounds
        _scrollView.contentSize = CGSize(width: self.sizeW * 3, height: self.sizeH)
        _scrollView.delegate = self
        _scrollView.isPagingEnabled = true
        _scrollView.contentOffset = CGPoint(x: self.sizeW, y: 0)
        _scrollView.showsHorizontalScrollIndicator = false
        _scrollView.showsVerticalScrollIndicator = false
        self.addSubview(_scrollView)
    }
    
    private func configImgViews() {
        for index in 0..<3 {
            let imgV = UIImageView(frame: CGRect(x: CGFloat(index) * self.sizeW, y: 0, width: self.sizeW, height: self.sizeH))
            imgV.image = self.placeHolderImg
            _imgVList.append(imgV)
            _scrollView.addSubview(imgV)
        }
    }
    
    private func configCtrlView() {
        _pageCtlr.pageIndicatorTintColor = .gray
        _pageCtlr.isUserInteractionEnabled = false
        self.addSubview(_pageCtlr)
    }
}

extension BQBannerView: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.clearTimer()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var point:CGPoint = CGPoint.zero
        if targetContentOffset.pointee.x >= scrollView.sizeW * 1.5 {
            point = CGPoint(x: scrollView.sizeW * 2, y: 0)
            _index += 1
        }else if targetContentOffset.pointee.x < scrollView.sizeW * 0.5{
            point = CGPoint(x: 0, y: 0)
            _index -= 1
        }else {
            point = CGPoint(x: scrollView.sizeW, y: 0)
        }
        scrollView.setContentOffset(point, animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPoint(x: scrollView.sizeW, y: 0), animated: false)
        self.startTimer()
    }
}


extension BQBannerViewDelegate {
    func didClickDisView(bannerView: BQBannerView, imgV: UIImageView, item: NSInteger) {}
    func didScrollToDisView(bannerView: BQBannerView, imgV: UIImageView, item: NSInteger) {}
}
