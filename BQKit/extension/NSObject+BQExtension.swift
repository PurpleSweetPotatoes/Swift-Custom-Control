// *******************************************
//  File Name:      NSObject+BQExtension.swift       
//  Author:         MrBai
//  Created Date:   2019/9/18 2:44 PM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************
    

import UIKit

extension NSObject {
    var pointAddress: UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(self).toOpaque()
    }
    
    var jsonString: String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        } catch let err {
            return nil
        }
    }
    
    /// 类实例方法交换
    ///   - targetSel: 目标方法
    ///   - newSel: 替换方法
    @discardableResult
    static func exchangeMethod(targetSel: Selector, newSel: Selector) -> Bool {
        
        guard let before: Method = class_getInstanceMethod(self, targetSel),
            let after: Method = class_getInstanceMethod(self, newSel) else {
                return false
        }

        method_exchangeImplementations(before, after)
        return true
    }
}
