// *******************************************
//  File Name:      UIAlertController+BQExtension.swift       
//  Author:         MrBai
//  Created Date:   2019/8/15 2:24 PM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************
    

import UIKit

extension UIAlertController {
    
    class public func showAlert(content:String, title:String? = nil, handle:(() -> Void)? = nil) {
        self.showAlert(content: content, title: title, btnTitleArr: ["确定"]) { (index) in
            if let block = handle {
                block()
            }
        }
    }
    
    class public func showAlert(content:String, title:String? = nil, btnTitleArr:Array<String>,handle:@escaping ((_ index:Int) -> Void)) {
        let alertVc:UIAlertController = UIAlertController(title: title, message: content, preferredStyle: .alert);
        for (index, title) in btnTitleArr.enumerated() {
            let action:UIAlertAction = UIAlertAction(title: title, style: .default, handler: { (action) in
                handle(index)
            })
            alertVc.addAction(action)
        }
        self.currentVc()?.present(alertVc, animated: true, completion: nil)
    }
}
