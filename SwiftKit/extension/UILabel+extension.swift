//
//  UILabel+extension.swift
//  swift-Test
//
//  Created by MrBai on 2017/6/14.
//  Copyright © 2017年 MrBai. All rights reserved.
//

import UIKit

extension UILabel {
    
    @discardableResult
    func adjustHeightForFont(spacing:CGFloat = 0) -> CGFloat {
        if let content = self.text {
            let rect = content.boundingRect(with: CGSize(width: self.sizeW, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: [NSAttributedStringKey.font:self.font], context: nil)
            self.sizeH = rect.height + spacing
            return rect.height
        }
        return self.sizeH
    }
    
    @discardableResult
    func adjustWidthForFont() -> CGFloat {
        if let content = self.text {
            let rect = content.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.sizeH), options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: [NSAttributedStringKey.font:self.font], context: nil)
            self.sizeW = rect.width
            return rect.width
        }
        return self.sizeW
    }
}
