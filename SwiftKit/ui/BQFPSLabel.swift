//
//  BQFPSLabel.swift
//  swift-Test
//
//  Created by MrBai on 2017/6/28.
//  Copyright © 2017年 MrBai. All rights reserved.
//

import UIKit

class BQFPSLabel: UILabel {
    
    //MARK: - ***** Ivars *****
    private var count: Int = 0
    private var lastTime: TimeInterval = 0
    private var link: CADisplayLink!
    //MARK: - ***** initialize Method *****
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initData()
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        self.link.invalidate()
        print("\(self.classForCoder) 释放了")
    }
    //MARK: - ***** private Method *****
    private func initData() {
        self.text = "60 fps"
        self.textAlignment = .center
        self.link = CADisplayLink(target: BQWeakProxy(target: self), selector: #selector(updateLink(link:)))
        self.link.add(to: RunLoop.main, forMode: .commonModes)
    }
    private func initUI() {
        self.backgroundColor = UIColor.white
    }
    //MARK: - ***** respond event Method *****
    @objc private func updateLink(link: CADisplayLink) {
        if self.lastTime == 0 {
            self.lastTime = link.timestamp
            return
        }
        count += 1
        let addTime = link.timestamp - self.lastTime
        if addTime < 1 {
            return
        }
        let fps = Int(round(Double(self.count) / addTime))
        self.count = 0
        self.lastTime = link.timestamp
        self.text = String("\(fps) fps")
    } 
}
