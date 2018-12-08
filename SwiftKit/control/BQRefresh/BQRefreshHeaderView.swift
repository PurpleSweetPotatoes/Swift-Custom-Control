//
//  BQRefreshHeaderView.swift
//  BQRefresh
//
//  Created by MrBai on 2017/7/5.
//  Copyright © 2017年 baiqiang. All rights reserved.
//

import UIKit

class BQRefreshHeaderView: BQRefreshView {
    
    //MARK: - ***** Ivars *****
    private var imgView = UIImageView(image: Bundle.arrowImage())
    private let loadingView = UIActivityIndicatorView(style: .gray)
    private let stateLab: UILabel = BQRefreshView.refreshLab()
    
    //MARK: - ***** initialize Method *****
    init(_ block:@escaping ()->()) {
        self.init()
        self.refreshBlock = block
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sizeH = 54
        self.top = -self.sizeH
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - ***** public Method *****
    
    public func endRefresh() {
        self.endAnimation()
    }
    
    override func layoutSubviews() {
        imgView.center = CGPoint(x: self.sizeW * 0.25, y: self.sizeH * 0.5)
        loadingView.center = imgView.center
        stateLab.frame = CGRect(x: 0, y: 0, width: self.sizeW, height: self.sizeH)
        super.layoutSubviews()
    }
    //MARK: - ***** private Method *****
    
    private func initUI() {
        
        self.addSubview(loadingView)
        loadingView.center = imgView.center
        loadingView.isHidden = true
        
        self.addSubview(self.stateLab)
        self.addSubview(imgView)
    }
    override func contentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.contentOffsetDidChange(change: change)
        if self.status == .refreshing {
            return
        }
        if (self.scrollView.contentOffset.y > self.scrollViewOriginalInset.top) || self.scrollView.contentOffset.y >= origiOffsetY {
            return
        }
        if self.scrollView.isDragging {
            switch self.status {
            case .pull:
                self.stateLab.text = Bundle.refreshString(key: .headerIdle)
                UIView.animate(withDuration: 0.25, animations: {
                    self.imgView.transform = CGAffineTransform.identity
                })
                if (origiOffsetY - self.scrollView.contentOffset.y) > self.sizeH {
                    self.status = .willRefresh
                }
            case .willRefresh:
                UIView.animate(withDuration: 0.25, animations: {
                    self.imgView.transform = CGAffineTransform(rotationAngle: CGFloat(0.0000001 - Double.pi))
                })
                self.stateLab.text = Bundle.refreshString(key: .headerPull)
                if (origiOffsetY - self.scrollView.contentOffset.y) <= self.sizeH {
                    self.status = .pull
                }
            default:
                break
            }
        }else {
            if self.status == .willRefresh {
                self.beginAnimation()
                self.refreshBlock()
            }else if self.status == .pull {
                self.endAnimation()
            }
        }
    }
    private func beginAnimation() {
        self.status = .refreshing
        
        self.imgView.transform = CGAffineTransform.identity
        self.imgView.isHidden = true
        self.loadingView.isHidden = false
        self.loadingView.startAnimating()
        self.stateLab.text = Bundle.refreshString(key: .headerRefresh)
        UIView.animate(withDuration: 0.25) {
            self.scrollView.contentInset = UIEdgeInsets(top: self.sizeH, left: 0, bottom: 0, right: 0)
        }
    }
    private func endAnimation() {
        self.status = .pull
        UIView.animate(withDuration: 0.25, animations: {
            self.scrollView.contentInset = UIEdgeInsets.zero
        }) { (flag) in
            self.imgView.isHidden = false
            self.loadingView.stopAnimating()
            self.loadingView.isHidden = true
        }
    }
}


