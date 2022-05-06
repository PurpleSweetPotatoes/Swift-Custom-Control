// *******************************************
//  File Name:      UITextField+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2022/5/6 22:55
//
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    
import UIKit

public extension UITextField {
    @discardableResult
    func leftTitle(title: String) -> UILabel {
        let lab = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: sizeH), font: font, text: title, textColor: .black, alignment: .left)
        lab.adjustWidth(spacing: 20)
        leftView = lab
        leftViewMode = .always
        return lab
    }
    
    func setRightArrow() -> UIView {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        
        let imgV = UIImageView(frame: CGRect(x: 14, y: 4, width: 6, height: 12))
        
        imgV.image = UIImage.arrowImg(size: CGSize(width: imgV.sizeW, height: imgV.sizeH), color: .gray, lineWidth: 1, direction: ArrowDirection.right)
        v.addSubview(imgV)
        
        rightView = v
        rightViewMode = .always
        return v
    }
}
