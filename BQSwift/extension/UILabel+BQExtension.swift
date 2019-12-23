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

extension UILabel {
    
    convenience init(frame: CGRect, font: UIFont? = nil, text: String? = nil, textColor: UIColor? = nil, alignment: NSTextAlignment = .left) {
        self.init(frame: frame)
        self.font = font
        self.text = text
        self.textColor = textColor
        self.textAlignment = alignment
    }
    
    @discardableResult
    func adjustHeight(spacing:CGFloat = 0, isAttribute:Bool = false) -> CGRect {
        var rect = CGRect.zero
        if isAttribute, let attribute = self.attributedText {
            rect = attribute.boundingRect(with: CGSize(width: self.sizeW, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin,.usesFontLeading], context: nil)
            self.sizeH = rect.height + spacing
        } else if let content = self.text {
            rect = content.boundingRect(with: CGSize(width: self.sizeW, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: self.labStatu(), context: nil)
            self.sizeH = rect.height + spacing
        }
        return rect
    }
    
    @discardableResult
    func adjustWidth(spacing:CGFloat = 0, isAttribute:Bool = false) -> CGRect {
        var rect = CGRect.zero
        if isAttribute, let attribute = self.attributedText {
            rect = attribute.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.sizeH), options: [.usesLineFragmentOrigin,.usesFontLeading], context: nil)
            self.sizeW = rect.width + spacing
        } else if let content = self.text {
            rect = content.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.sizeH), options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: self.labStatu(), context: nil)
            self.sizeW = rect.width + spacing
        }
        return rect
    }
    
    func labStatu() -> [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = self.lineBreakMode;
        
        return [NSAttributedString.Key.font : self.font ?? UIFont.systemFont(ofSize: 16),
                   NSAttributedString.Key.paragraphStyle: style]
    }
}
