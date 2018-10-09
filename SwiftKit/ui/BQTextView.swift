//
//  BQTextView.swift
//  swift-Test
//
//  Created by MrBai on 2017/6/28.
//  Copyright © 2017年 MrBai. All rights reserved.
//

import UIKit

protocol BQTextViewDelegate: NSObjectProtocol {
/// 可选方法
    
    func textViewDidHasMaxNum(textView: BQTextView) -> Void
    func textViewDidAdjustFrame(textView: BQTextView) -> Void
    
    func textViewShouldBeginEditing(textView: BQTextView) -> Bool
    func textViewShouldEndEditing(textView: BQTextView) -> Bool
    
    func textViewDidBeginEditing(textView: BQTextView) -> Void
    func textViewDidEndEditing(textView: BQTextView) -> Void
    
    func textViewDidChange(textView: BQTextView) -> Void
    
}



/// 默认有最小高度，e根据font自动设置
class BQTextView: UITextView {

    //MARK: - ***** Ivars *****
    open var ourDelegate: BQTextViewDelegate?
    open var limitLenght: Int = 1000
    open var autoAdjustHeight: Bool = false
    open var placeholder: String! {
        didSet {
            self.placeLab.text = placeholder
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    open var placeholderColor: UIColor! = UIColor.gray {
        didSet {
            self.placeLab.textColor = placeholderColor
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    //should set autoAdjustHeight is true can use
    open var maxHeight: CGFloat = 400   ///< defualt is init height
    
    private var lastHeight: CGFloat = 32
    private let placeLab: UILabel = {
        let lab = UILabel(frame: CGRect.zero)
        lab.numberOfLines = 0
        return lab
    }()
    
    override var text: String! {
        didSet {
            self.refreshPlaceholder()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    override var font: UIFont? {
        didSet {
            self.placeLab.font = font
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    override var textAlignment: NSTextAlignment {
        didSet {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    //MARK: - ***** initialize Method *****
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.configUI()
    }
    
    init(frame: CGRect, holder: String? = "", color: UIColor? = UIColor.gray) {
        super.init(frame: frame, textContainer: nil)
        self.placeholder = holder
        self.placeholderColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - ***** private Method *****
    private func configUI() {
        
        self.font = UIFont.systemFont(ofSize: 15)
        self.addSubview(self.placeLab)
        self.placeLab.font = self.font
        self.placeLab.sizeW = self.sizeW
        self.placeLab.text = self.placeholder
        self.placeLab.textColor = self.placeholderColor
        
        self.delegate = self
        
    }
    
    private func adjustFrames() {
        
        if (self.autoAdjustHeight && self.contentSize.height <= self.maxHeight) {
            
            var frame = self.frame;
            frame.size = self.contentSize;
            self.frame = frame;
            self.lastHeightCompareWithHeight(height: frame.size.height)
            
        } else if (self.contentSize.height > self.maxHeight) {
            
            self.sizeH = self.maxHeight;
            self.lastHeightCompareWithHeight(height: self.sizeH)
        }
        
        self.adjustLabelFrameAndMinHeight()
        
    }
    
    private func lastHeightCompareWithHeight(height: CGFloat) {
        
        if (lastHeight != height) {
            lastHeight = height;
            self.ourDelegate?.textViewDidAdjustFrame(textView: self)
        }
    }

    private func adjustLabelFrameAndMinHeight() {
        
        let offsetLeft = self.textContainerInset.left + self.textContainer.lineFragmentPadding;
        let offsetRight = self.textContainerInset.right + self.textContainer.lineFragmentPadding;
        let offsetTop = self.textContainerInset.top;
        let offsetBottom = self.textContainerInset.bottom;
        
        let size = self.placeLab.sizeThatFits(CGSize(width: self.sizeW - offsetLeft - offsetRight, height: self.sizeH - offsetTop - offsetBottom))
        
        self.placeLab.frame = CGRect(x: offsetLeft, y: offsetTop, width: size.width, height: size.height)
        
        var minHeight = self.placeLab.sizeH
        
        if minHeight <= self.font!.lineHeight {
            minHeight = self.font!.lineHeight
        }
        
        if self.sizeH < minHeight + offsetTop + offsetBottom {
            self.sizeH = minHeight + offsetTop + offsetBottom
        }
    }
    
    private func refreshPlaceholder() {
        self.placeLab.isHidden = self.hasText
    }
    
    //MARK: - ***** Override Method *****
    override func layoutSubviews() {
        self.adjustFrames()
        super.layoutSubviews()
    }

}

extension BQTextView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (textView.text.count + text.count <= self.limitLenght) {
            return true
        }
        self.ourDelegate?.textViewDidHasMaxNum(textView: self)
        return false
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return self.ourDelegate?.textViewShouldBeginEditing(textView: self) ?? true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.ourDelegate?.textViewDidBeginEditing(textView: self)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return self.ourDelegate?.textViewShouldEndEditing(textView: self) ?? true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.ourDelegate?.textViewDidEndEditing(textView: self)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.refreshPlaceholder()
        self.ourDelegate?.textViewDidChange(textView: self)
    }
    
}


extension BQTextViewDelegate {
    
    func textViewDidHasMaxNum(textView: BQTextView) -> Void {
        
    }
    
    func textViewDidAdjustFrame(textView: BQTextView) -> Void {
        
    }
    
    func textViewShouldBeginEditing(textView: BQTextView) -> Bool {
        return true
    }
    func textViewShouldEndEditing(textView: BQTextView) -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(textView: BQTextView) -> Void {
        
    }
    func textViewDidEndEditing(textView: BQTextView) -> Void {
        
    }
    
    func textViewDidChange(textView: BQTextView) -> Void {
        
    }
}
