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
        if let delegate = self.delegate {
            
            if self.itemHeight == 0 {
                self.itemHeight = (self.sizeW - self.itemSpace * 2) / 3
            } else {
                var frame = self.frame
                let width = self.itemHeight * 3 + self.itemSpace * 2
                frame.size = CGSize(width: width, height: width)
                self.frame = frame
            }
            
            self.adjustSubViewFrame(number: delegate.numberOfImages(nineView:self))
        } else {
            for imgV in _imgVList {
                imgV.isHidden = true
            }
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.reloadData()
    }
    
    // MARK: - private method
    private func adjustSubViewFrame(number: Int) {
        showVList.removeAll()
        for (index, imgV) in _imgVList.enumerated() {
            imgV.frame = CGRect(x: CGFloat(index % 3) * (self.itemHeight + self.itemSpace), y: CGFloat(index / 3) * (self.itemHeight + self.itemSpace), width: self.itemHeight, height: self.itemHeight)
            imgV.isHidden = index >= number
            if index < number {
                showVList.append(imgV)
                self.delegate!.prepareNineView(nineView: self, imgV: imgV, item: index)
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
    private func configUI() {
        for tag in 0..<9 {
            let imgV = UIImageView()
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.imgVTapAction(tap:)))
            imgV.isUserInteractionEnabled = true
            imgV.addGestureRecognizer(tap)
            imgV.tag = tag
            imgV.isHidden = true
            self.addSubview(imgV)
            _imgVList.append(imgV)
        }
    }

}

extension BQNineImgsViewDelegate {
    func imgVSelect(nineView: BQNineImgsView, imgV: UIImageView, item: NSInteger) {}
}
