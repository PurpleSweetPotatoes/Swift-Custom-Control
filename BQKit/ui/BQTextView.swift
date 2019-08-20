// *******************************************
//  File Name:      BQTextView.swift       
//  Author:         MrBai
//  Created Date:   2019/8/19 2:50 PM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************
    

import UIKit

protocol BQTextViewDelegate {
    /// 可选方法
    func textViewDidHasMaxNum(textView: BQTextView) -> Void
    func textViewDidAdjustFrame(textView: BQTextView) -> Void
    
    func textViewShouldBeginEditing(textView: BQTextView) -> Bool
    func textViewShouldEndEditing(textView: BQTextView) -> Bool
    
    func textViewDidBeginEditing(textView: BQTextView) -> Void
    func textViewDidEndEditing(textView: BQTextView) -> Void
    
    func textViewDidChange(textView: BQTextView) -> Void
    
}


class BQTextView: UITextView {

    // MARK: - var
    open var textDelegate: BQTextViewDelegate?
    open var limitLenght: Int = 1000
    open var autoAdjustHeight: Bool = false
    
    open var maxHeight: CGFloat = 400   ///< defualt is init height
    open var minHeight: CGFloat?        ///< defualt is 0
    
    private let placeLab: UILabel = {
        let lab = UILabel(frame: CGRect.zero)
        lab.numberOfLines = 0
        return lab
    }()
    
    override var font: UIFont? {
        didSet {
            self.placeLab.font = font
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    
    // MARK: - creat

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configUI()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.configUI()
    }
    
    convenience init(frame: CGRect, holder: String? = nil, color: UIColor = UIColor.gray) {
        self.init(frame: frame, textContainer: nil)
        self.configHolder(placeHolder: holder, color: color)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - public method
    
    func configHolder(placeHolder: String?, color: UIColor = UIColor.gray) {
        self.placeLab.text = placeHolder
        self.placeLab.textColor = color
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.adjustFrames()
    }
    
    // MARK: - private method
    
    private func adjustFrames() {
    
        self.refreshPlaceholder()
        
        if self.autoAdjustHeight {
            let minHieght = self.minHeight ?? (self.font!.lineHeight + self.textContainerInset.top + self.textContainerInset.bottom)
            if self.sizeH != self.contentSize.height || self.sizeH < minHieght {
                self.setContentOffset(CGPoint.zero, animated: false)
                self.sizeH = self.contentSize.height >= minHieght ? self.contentSize.height : minHieght
                self.textDelegate?.textViewDidAdjustFrame(textView: self)
            }
        }
        
        self.adjustLabelFrameAndMinHeight()
    }
    
    private func adjustLabelFrameAndMinHeight() {
        if self.placeLab.alpha != 0 {
            let offsetLeft = self.textContainerInset.left + self.textContainer.lineFragmentPadding;
            let offsetRight = self.textContainerInset.right + self.textContainer.lineFragmentPadding;
            
            let size = self.placeLab.sizeThatFits(CGSize(width: self.sizeW - offsetLeft - offsetRight, height: self.sizeH))
            
            self.placeLab.frame = CGRect(x: offsetLeft, y: self.textContainerInset.top, width: size.width, height: size.height)
        }
    }
    
    private func refreshPlaceholder() {
        self.placeLab.isHidden = self.hasText
    }

    // MARK: - UI method
    
    private func configUI() {
        self.font = UIFont.systemFont(ofSize: 15)
        self.placeLab.font = self.font
        self.placeLab.sizeW = self.sizeW
        self.addSubview(self.placeLab)
        self.delegate = self
    }

}

extension BQTextView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (textView.text.count + text.count <= self.limitLenght) {
            return true
        }
        self.textDelegate?.textViewDidHasMaxNum(textView: self)
        return false
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return self.textDelegate?.textViewShouldBeginEditing(textView: self) ?? true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.textDelegate?.textViewDidBeginEditing(textView: self)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return self.textDelegate?.textViewShouldEndEditing(textView: self) ?? true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.textDelegate?.textViewDidEndEditing(textView: self)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.refreshPlaceholder()
        self.textDelegate?.textViewDidChange(textView: self)
    }
    
}


extension BQTextViewDelegate {
    
    func textViewDidHasMaxNum(textView: BQTextView) -> Void {
        print("达到最大字数限制")
    }
    
    func textViewDidAdjustFrame(textView: BQTextView) -> Void {
        print("Frame改变")
    }
    
    func textViewShouldBeginEditing(textView: BQTextView) -> Bool {
        return true
    }
    func textViewShouldEndEditing(textView: BQTextView) -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(textView: BQTextView) -> Void {
        print("已经开始编辑")
    }
    func textViewDidEndEditing(textView: BQTextView) -> Void {
        print("结束编辑")
    }
    
    func textViewDidChange(textView: BQTextView) -> Void {
        print("文字改变")
    }
}
