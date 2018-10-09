//
//  BQRefreshFooterView.swift
//  BQRefresh
//
//  Created by MrBai on 2017/7/5.
//  Copyright © 2017年 baiqiang. All rights reserved.
//

import UIKit

class BQRefreshFooterView: BQRefreshView {

    //MARK: - ***** Ivars *****
    private let loadingView = UIActivityIndicatorView(style: .gray)
    private let stateLab: UILabel = BQRefreshView.refreshLab()
    private var updateHeight: CGFloat = 0
    private var resetContentSize: Bool = false

    //MARK: - ***** initialize Method *****
    init(_ block:@escaping ()->()) {
        self.init()
        self.refreshBlock = block
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sizeH = 44
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - ***** public Method *****
    
    func endRefresh(noMore:Bool) {
        self.loadingView.stopAnimating()
        self.loadingView.isHidden = true
        if noMore {
            self.stateLab.text = Bundle.refreshString(key: .footNoMore)
            self.status = .noMoreData
        }else {
            self.stateLab.text = Bundle.refreshString(key: .footIdle)
            self.status = .pull
        }
    }
    
    override func layoutSubviews() {
        loadingView.center = CGPoint(x: self.sizeW * 0.25, y: self.sizeH * 0.5)
        stateLab.frame = CGRect(x: 0, y: 0, width: self.sizeW, height: self.sizeH)
        super.layoutSubviews()
    }
    //MARK: - ***** private Method *****
    private func initUI() {
        self.addSubview(self.stateLab)
        self.stateLab.frame = self.bounds
        self.stateLab.text = Bundle.refreshString(key: .footIdle)
        self.addSubview(self.loadingView)
        self.loadingView.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(beginAnimation))
        self.addGestureRecognizer(tap)
    }
    @objc private func beginAnimation() {
        self.status = .refreshing
        self.stateLab.text = Bundle.refreshString(key: .footRefresh)
        self.loadingView.isHidden = false
        self.loadingView.startAnimating()
        self.refreshBlock()
    }
    //MARK: - ***** respond event Method *****
    override func contentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.contentOffsetDidChange(change: change)
        
        //刷新、下拉、无更多数据返回
        if self.status == .refreshing || self.status == .noMoreData || (origiOffsetY - self.scrollView.contentOffset.y) > 0{
            return
        }

        if self.scrollView.isDragging {
            switch self.status {
            case .pull:
                if self.scrollView.contentSize.height < self.scrollView.sizeH + self.scrollView.contentOffset.y {
                    self.status = .willRefresh
                }
            case .willRefresh:
                self.beginAnimation()
            default:
                break
            }
        }
    }
    
    override func contentSizeDidChange(change: [NSKeyValueChangeKey : Any]?) {
        if !self.resetContentSize {
            self.resetContentSize = true
            self.top = self.scrollView.contentSize.height
            self.scrollView.contentSize = CGSize(width: self.sizeW, height: self.scrollView.contentSize.height + self.sizeH)
            self.resetContentSize = false
        }
    }
}
