//
//  BQTextView.swift
//  swift-Test
//
//  Created by MrBai on 2017/6/28.
//  Copyright © 2017年 MrBai. All rights reserved.
//

import UIKit

class BQTextView: UITextView {

    //MARK: - ***** Ivars *****
    private var placeHolder: String?
    override var font: UIFont? {
        get {
            return super.font
        }
        set {
            if let font = newValue {
                super.font = font
                self.placeLab.font = font
                self.placeLab.adjustHeightForFont()
            }
        }
    }
    private let placeLab: UILabel = {
        let lab = UILabel(frame: CGRect.zero)
        lab.numberOfLines = 0
        lab.textColor = UIColor.gray
        return lab
    }()
    //MARK: - ***** Class Method *****
    
    //MARK: - ***** initialize Method *****
    
    init(frame: CGRect, holder: String, font: UIFont? = nil) {
        super.init(frame: frame, textContainer: nil)
        self.placeHolder = holder
        self.font = font
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: - ***** public Method *****
    func placeHolderColor(color: UIColor)  {
        self.placeLab.textColor = color
    }
    //MARK: - ***** private Method *****
    private func initUI() {
        self.addSubview(self.placeLab)
        self.placeLab.font = self.font
        self.placeLab.sizeW = self.sizeW
        self.placeLab.text = self.placeHolder
        let spaing: CGFloat = 8;
        self.placeLab.top = spaing
        self.placeLab.left = spaing / 2.0
        self.placeLab.sizeW = self.sizeW - spaing
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChage), name: .UITextViewTextDidChange, object: self)
    }
    //MARK: - ***** LoadData Method *****
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentInset = UIEdgeInsets.zero
        self.placeLab.adjustHeightForFont()
    }
    //MARK: - ***** respond event Method *****
    @objc private func textDidChage() {
        self.placeLab.isHidden = self.hasText
    }
    //MARK: - ***** Protocol *****
    
    //MARK: - ***** create Method *****

}
