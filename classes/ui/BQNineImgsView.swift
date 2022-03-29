// *******************************************
//  File Name:      BQNineImgsView.swift
//  Author:         MrBai
//  Created Date:   2019/8/21 1:53 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

protocol BQNineImgsViewDelegate: NSObjectProtocol {
    func numberOfImages(nineView: BQNineImgsView) -> Int
    func prepareNineView(nineView: BQNineImgsView, imgV: UIImageView, item: NSInteger)
    func imgVSelect(nineView: BQNineImgsView, imgV: UIImageView, item: NSInteger)
}

class BQNineImgsView: UIView {
    // MARK: - var

    var itemHeight: CGFloat = 0
    var itemSpace: CGFloat = 0
    weak var delegate: BQNineImgsViewDelegate?
    private var _imgVList = [UIImageView]()

    var showVList = [UIImageView]()

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
        if let delegate = self.delegate {
            if itemHeight == 0 {
                itemHeight = (sizeW - itemSpace * 2) / 3
            } else {
                var frame = self.frame
                let width = itemHeight * 3 + itemSpace * 2
                frame.size = CGSize(width: width, height: width)
                self.frame = frame
            }

            adjustSubViewFrame(number: delegate.numberOfImages(nineView: self))
        } else {
            for imgV in _imgVList {
                imgV.isHidden = true
            }
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        reloadData()
    }

    // MARK: - private method

    private func adjustSubViewFrame(number: Int) {
        showVList.removeAll()
        for (index, imgV) in _imgVList.enumerated() {
            imgV.frame = CGRect(x: CGFloat(index % 3) * (itemHeight + itemSpace), y: CGFloat(index / 3) * (itemHeight + itemSpace), width: itemHeight, height: itemHeight)
            imgV.isHidden = index >= number
            if index < number {
                showVList.append(imgV)
                delegate!.prepareNineView(nineView: self, imgV: imgV, item: index)
            }
        }
    }

    // MARK: - Event method

    @objc func imgVTapAction(tap: UITapGestureRecognizer) {
        if tap.state == .ended, let delegate = self.delegate {
            let imgV = tap.view as! UIImageView
            delegate.imgVSelect(nineView: self, imgV: imgV, item: imgV.tag)
        }
    }

    // MARK: - UI method

    func configUI() {
        for tag in 0 ..< 9 {
            let imgV = UIImageView()
            let tap = UITapGestureRecognizer(target: self, action: #selector(imgVTapAction(tap:)))
            imgV.isUserInteractionEnabled = true
            imgV.addGestureRecognizer(tap)
            imgV.tag = tag
            imgV.isHidden = true
            addSubview(imgV)
            _imgVList.append(imgV)
        }
    }
}

extension BQNineImgsViewDelegate {
    func imgVSelect(nineView _: BQNineImgsView, imgV _: UIImageView, item _: NSInteger) {}
}
