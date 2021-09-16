// *******************************************
//  File Name:      UIBarItem+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/8/22 12:00 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

public extension UIBarItem {
    func configAttributes(fontSize: CGFloat, textColor: UIColor) {
        configAttributes(font: UIFont.systemFont(ofSize: fontSize), textColor: textColor)
    }

    func configAttributes(font: UIFont? = nil, textColor: UIColor) {
        let textInfo = BQTextAttributes()
        textInfo.textColor(textColor)
        if let fontV = font {
            textInfo.font(fontV)
        }
        setTextInfo(textInfo: textInfo, state: .normal)
    }

    func setTextInfo(textInfo: BQTextAttributes, state: UIControl.State) {
        setTitleTextAttributes(textInfo.dictionary, for: state)
    }
}
