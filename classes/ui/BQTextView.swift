// *******************************************
//  File Name:      BQTextView.swift
//  Author:         MrBai
//  Created Date:   2019/8/19 2:50 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

public protocol BQTextViewDelegate: NSObjectProtocol {
    /// 可选方法
    func textViewDidHasMaxNum(textView: BQTextView) -> Void
    func textViewDidAdjustFrame(textView: BQTextView) -> Void

    func textViewShouldBeginEditing(textView: BQTextView) -> Bool
    func textViewShouldEndEditing(textView: BQTextView) -> Bool

    func textViewDidBeginEditing(textView: BQTextView) -> Void
    func textViewDidEndEditing(textView: BQTextView) -> Void

    func textViewDidChange(textView: BQTextView) -> Void
}

public final class BQTextView: UITextView {
    // MARK: - var

    public weak var textDelegate: BQTextViewDelegate?
    public var limitLenght: Int = 1000
    public var autoAdjustHeight: Bool = false

    public var maxHeight: CGFloat = 400 /// < defualt is init height
    public var minHeight: CGFloat? /// < defualt is 0

    private let placeLab: UILabel = {
        let lab = UILabel(frame: CGRect.zero)
        lab.numberOfLines = 0
        return lab
    }()

    override public var font: UIFont? {
        didSet {
            self.placeLab.font = font
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    // MARK: - creat

    override public func awakeFromNib() {
        super.awakeFromNib()
        configUI()
    }

    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        configUI()
    }

    public convenience init(frame: CGRect, holder: String? = nil, color: UIColor = UIColor.gray) {
        self.init(frame: frame, textContainer: nil)
        configHolder(placeHolder: holder, color: color)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - public method

    public func configHolder(placeHolder: String?, color: UIColor = UIColor.gray) {
        placeLab.text = placeHolder
        placeLab.textColor = color
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        adjustFrames()
    }

    // MARK: - private method

    private func adjustFrames() {
        refreshPlaceholder()

        if autoAdjustHeight {
            let minHieght = minHeight ?? (font!.lineHeight + textContainerInset.top + textContainerInset.bottom)
            if sizeH != contentSize.height || sizeH < minHieght {
                setContentOffset(CGPoint.zero, animated: false)
                sizeH = contentSize.height >= minHieght ? contentSize.height : minHieght
                textDelegate?.textViewDidAdjustFrame(textView: self)
            }
        }

        adjustLabelFrameAndMinHeight()
    }

    private func adjustLabelFrameAndMinHeight() {
        if placeLab.alpha != 0 {
            let offsetLeft = textContainerInset.left + textContainer.lineFragmentPadding
            let offsetRight = textContainerInset.right + textContainer.lineFragmentPadding

            let size = placeLab.sizeThatFits(CGSize(width: sizeW - offsetLeft - offsetRight, height: sizeH))

            placeLab.frame = CGRect(x: offsetLeft, y: textContainerInset.top, width: size.width, height: size.height)
        }
    }

    private func refreshPlaceholder() {
        placeLab.isHidden = hasText
    }

    // MARK: - UI method

    func configUI() {
        font = UIFont.systemFont(ofSize: 15)
        placeLab.font = font
        placeLab.sizeW = sizeW
        addSubview(placeLab)
        delegate = self
    }
}

extension BQTextView: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn _: NSRange, replacementText text: String) -> Bool {
        if textView.text.count + text.count <= limitLenght {
            return true
        }
        textDelegate?.textViewDidHasMaxNum(textView: self)
        return false
    }

    public func textViewShouldBeginEditing(_: UITextView) -> Bool {
        return textDelegate?.textViewShouldBeginEditing(textView: self) ?? true
    }

    public func textViewDidBeginEditing(_: UITextView) {
        textDelegate?.textViewDidBeginEditing(textView: self)
    }

    public func textViewShouldEndEditing(_: UITextView) -> Bool {
        return textDelegate?.textViewShouldEndEditing(textView: self) ?? true
    }

    public func textViewDidEndEditing(_: UITextView) {
        textDelegate?.textViewDidEndEditing(textView: self)
    }

    public func textViewDidChange(_: UITextView) {
        refreshPlaceholder()
        textDelegate?.textViewDidChange(textView: self)
    }
}

extension BQTextViewDelegate {
    func textViewDidHasMaxNum(textView _: BQTextView) {
        BQLogger.log("达到最大字数限制")
    }

    func textViewDidAdjustFrame(textView _: BQTextView) {
        BQLogger.log("Frame改变")
    }

    func textViewShouldBeginEditing(textView _: BQTextView) -> Bool {
        return true
    }

    func textViewShouldEndEditing(textView _: BQTextView) -> Bool {
        return true
    }

    func textViewDidBeginEditing(textView _: BQTextView) {
        BQLogger.log("已经开始编辑")
    }

    func textViewDidEndEditing(textView _: BQTextView) {
        BQLogger.log("结束编辑")
    }

    func textViewDidChange(textView _: BQTextView) {
        BQLogger.log("文字改变")
    }
}
