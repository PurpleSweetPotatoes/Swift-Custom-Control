// *******************************************
//  File Name:      UILabel+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/8/15 3:21 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import Foundation

import UIKit

public extension UILabel {
    convenience init(frame: CGRect, font: UIFont? = nil, text: String? = nil, textColor: UIColor? = nil, alignment: NSTextAlignment = .left) {
        self.init(frame: frame)
        self.font = font
        self.text = text
        self.textColor = textColor
        textAlignment = alignment
    }

    @discardableResult
    func adjustHeight(spacing: CGFloat = 0, isAttribute: Bool = false) -> CGRect {
        var rect = CGRect.zero
        if isAttribute, let attribute = attributedText {
            rect = attribute.boundingRect(with: CGSize(width: sizeW, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
            sizeH = rect.height + spacing
        } else if let content = text {
            rect = content.boundingRect(with: CGSize(width: sizeW, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: labStatu(), context: nil)
            sizeH = rect.height + spacing
        }
        return rect
    }

    @discardableResult
    func adjustWidth(spacing: CGFloat = 0, isAttribute: Bool = false) -> CGRect {
        var rect = CGRect.zero
        if isAttribute, let attribute = attributedText {
            rect = attribute.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: sizeH), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
            sizeW = rect.width + spacing
        } else if let content = text {
            rect = content.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: sizeH), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: labStatu(), context: nil)
            sizeW = rect.width + spacing
        }
        return rect
    }

    func labStatu() -> [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = numberOfLines == 0 ? .byWordWrapping : lineBreakMode

        return [NSAttributedString.Key.font: font ?? UIFont.systemFont(ofSize: 16),
                NSAttributedString.Key.paragraphStyle: style]
    }
}
