//
//  UIAlertController+extension.swift
//  swift4.2Demo
//
//  Created by baiqiang on 2018/10/8.
//  Copyright © 2018年 baiqiang. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    class func showAlert(content:String, title:String? = nil, handle:(() -> ())? = nil) {
        self.showAlert(content: content, title: title, btnTitleArr: ["确定"]) { (index) in
            if let block = handle {
                block()
            }
        }
    }
    
    class func showAlert(content:String, title:String? = nil, btnTitleArr:Array<String>,handle:@escaping ((_ index:Int) -> Void)) {
        let alertVc:UIAlertController = UIAlertController(title: title, message: content, preferredStyle: .alert);
        for title in btnTitleArr {
            let action:UIAlertAction = UIAlertAction(title: title, style: .default, handler: { (action) in
                let index = btnTitleArr.index(of: action.title!)
                handle(index!)
            })
            alertVc.addAction(action)
        }
        self.currentVc()?.present(alertVc, animated: true, completion: nil)
    }
}
