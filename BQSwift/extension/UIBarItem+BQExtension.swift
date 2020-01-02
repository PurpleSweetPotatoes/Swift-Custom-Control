// *******************************************
//  File Name:      UIBarItem+BQExtension.swift       
//  Author:         MrBai
//  Created Date:   2019/8/22 12:00 PM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************
    

import UIKit

extension UIBarItem {
    
    public func configAttributes(fontSize: CGFloat, textColor: UIColor) {
        self.configAttributes(font: UIFont.systemFont(ofSize: fontSize), textColor: textColor)
    }
    
    public func configAttributes(font: UIFont? = nil, textColor: UIColor) {
        let textInfo = BQTextAttributes()
        textInfo.textColor(textColor)
        if let fontV = font {
            textInfo.font(fontV)
        }
        self.setTextInfo(textInfo: textInfo, state: .normal)
    }
    
    
    public func setTextInfo(textInfo: BQTextAttributes, state: UIControl.State) {
        self.setTitleTextAttributes(textInfo.dictionary, for: state)
    }
}
