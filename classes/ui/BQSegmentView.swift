// *******************************************
//  File Name:      BQSegmentView.swift
//  Author:         MrBai
//  Created Date:   2022/5/15 17:27
//
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import UIKit

public class BQSegmentView: UIView {
    // MARK: - *** Ivars

    private let btnTag = 100
    private var titles: [String] = []
    private var preBtn: UIButton?
    private var block: IntBlock?
    
    public var currentIndex: Int = 0 {
        didSet {
            if currentIndex < titles.count {
                if let btn = viewWithTag(currentIndex + btnTag) as? UIButton {
                    reConfigBtnState(btn)
                }
            } else {
                currentIndex = oldValue
            }
        }
    }

    // MARK: - *** Public method

    public func configBtnClickBlock(_ block: @escaping IntBlock) {
        self.block = block
    }
    // MARK: - *** Life cycle

    public convenience init(frame: CGRect, titleList: [String]) {
        self.init(frame: frame)
        titles = titleList
        configUI()
    }

    // MARK: - *** NetWork method

    // MARK: - *** Event Action
    @objc private func segmentBtnClick(_ sender: UIButton) {
        if sender == preBtn {
            return
        }
        reConfigBtnState(sender)
        block?(sender.tag - btnTag)
    }
    // MARK: - *** Delegate

    // MARK: - *** Instance method

    // MARK: - *** UI method

    private func configUI() {
        let btnWidth = sizeW / CGFloat(titles.count)
        for (i, btnTitle) in titles.enumerated() {
            let btn = UIButton(type: .custom)
            btn.frame = CGRect(x: CGFloat(i) * btnWidth, y: 0, width: btnWidth, height: sizeH)
            btn.setTitle(btnTitle, for: [.normal, .selected])
            btn.setTitleColor( .white, for: .normal)
            btn.setTitleColor( .red, for: .selected)
            btn.tag = i + btnTag
            btn.addTarget(self, action: #selector(segmentBtnClick(_:)), for: .touchUpInside)
            addSubview(btn)
        }
        if let btn = viewWithTag(0 + btnTag) as? UIButton {
            segmentBtnClick(btn)
        }
    }
    
    private func reConfigBtnState(_ sender: UIButton) {
        preBtn?.isSelected = false
        sender.isSelected = true
        preBtn = sender
    }


    // MARK: - *** Ivar Getter
}
