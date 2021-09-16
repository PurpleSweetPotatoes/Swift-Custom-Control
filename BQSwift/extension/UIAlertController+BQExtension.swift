// *******************************************
//  File Name:      UIAlertController+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/8/15 2:24 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

public extension UIAlertController {
    class func showAlert(content: String, title: String? = nil, handle: (() -> Void)? = nil) {
        showAlert(content: content, title: title, btnTitleArr: ["确定"]) { _ in
            if let block = handle {
                block()
            }
        }
    }

    class func showAlert(content: String, title: String? = nil, btnTitleArr: [String], handle: @escaping ((_ index: Int) -> Void)) {
        let alertVc = UIAlertController(title: title, message: content, preferredStyle: .alert)
        for (index, title) in btnTitleArr.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: { _ in
                handle(index)
            })
            alertVc.addAction(action)
        }
        currentVc()?.present(alertVc, animated: true, completion: nil)
    }
}
