// *******************************************
//  File Name:      BQBannerView.swift
//  Author:         MrBai
//  Created Date:   2019/8/20 11:00 AM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

protocol BQBannerViewDelegate: NSObjectProtocol {
    func numberOfBannerItems(bannerView: BQBannerView) -> NSInteger
    func prepareDisView(bannerView: BQBannerView, imgV: UIImageView, item: NSInteger)

    func didClickDisView(bannerView: BQBannerView, imgV: UIImageView, item: NSInteger)
    func didScrollToDisView(bannerView: BQBannerView, imgV: UIImageView, item: NSInteger)
}

class BQBannerView: UIView {
    // MARK: - var

    weak var delegate: BQBannerViewDelegate?
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
        configUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - public method

    func reloadData() {
        _index = 0
        if showPageCtrl {
            _pageCtlr.currentPage = _index
            _pageCtlr.numberOfPages = delegate?.numberOfBannerItems(bannerView: self) ?? 0
            let size = _pageCtlr.size(forNumberOfPages: _pageCtlr.numberOfPages)
            _pageCtlr.frame = CGRect(x: (sizeW - size.width) * 0.5, y: sizeH - size.height, width: size.width, height: size.height)
        }
        startTimer()
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
                imgV.image = placeHolderImg
            }
            _scrollView.isUserInteractionEnabled = false
        }
    }

    private func startTimer() {
        if autoShowTime != 0 {
            if _timer == nil {
                _timer = Timer.scheduledTimer(timeInterval: autoShowTime, target: BQWeakProxy(target: self), selector: #selector(timeDidChange(timer:)), userInfo: nil, repeats: true)
                RunLoop.current.add(_timer!, forMode: .common)
            }
        } else {
            clearTimer()
        }
        reloadImgsInfo()
    }

    private func clearTimer() {
        _timer?.invalidate()
        _timer = nil
    }

    // MARK: - Event method

    @objc private func timeDidChange(timer _: Timer) {
        _index += 1
        _scrollView.setContentOffset(CGPoint(x: sizeW * 2, y: 0), animated: true)
    }

    @objc private func bannerTapGesturAction(tap: UITapGestureRecognizer) {
        print("点击事件")
        if tap.state == .ended {
            delegate?.didClickDisView(bannerView: self, imgV: _imgVList[1], item: _index)
        }
    }

    // MARK: - UI method

    func configUI() {
        configScrollView()
        configImgViews()
        configCtrlView()

        let tap = UITapGestureRecognizer(target: self, action: #selector(bannerTapGesturAction(tap:)))
        addGestureRecognizer(tap)
    }

    private func configScrollView() {
        _scrollView.frame = bounds
        _scrollView.contentSize = CGSize(width: sizeW * 3, height: sizeH)
        _scrollView.delegate = self
        _scrollView.isPagingEnabled = true
        _scrollView.contentOffset = CGPoint(x: sizeW, y: 0)
        _scrollView.showsHorizontalScrollIndicator = false
        _scrollView.showsVerticalScrollIndicator = false
        addSubview(_scrollView)
    }

    private func configImgViews() {
        for index in 0 ..< 3 {
            let imgV = UIImageView(frame: CGRect(x: CGFloat(index) * sizeW, y: 0, width: sizeW, height: sizeH))
            imgV.image = placeHolderImg
            _imgVList.append(imgV)
            _scrollView.addSubview(imgV)
        }
    }

    private func configCtrlView() {
        _pageCtlr.pageIndicatorTintColor = .gray
        _pageCtlr.isUserInteractionEnabled = false
        addSubview(_pageCtlr)
    }
}

extension BQBannerView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_: UIScrollView) {
        clearTimer()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity _: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var point = CGPoint.zero
        if targetContentOffset.pointee.x >= scrollView.sizeW * 1.5 {
            point = CGPoint(x: scrollView.sizeW * 2, y: 0)
            _index += 1
        } else if targetContentOffset.pointee.x < scrollView.sizeW * 0.5 {
            point = CGPoint(x: 0, y: 0)
            _index -= 1
        } else {
            point = CGPoint(x: scrollView.sizeW, y: 0)
        }
        scrollView.setContentOffset(point, animated: true)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPoint(x: scrollView.sizeW, y: 0), animated: false)
        startTimer()
    }
}

extension BQBannerViewDelegate {
    func didClickDisView(bannerView _: BQBannerView, imgV _: UIImageView, item _: NSInteger) {}
    func didScrollToDisView(bannerView _: BQBannerView, imgV _: UIImageView, item _: NSInteger) {}
}
