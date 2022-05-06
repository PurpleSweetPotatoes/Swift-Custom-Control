// *******************************************
//  File Name:      NSObject+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/9/18 2:44 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

public extension NSObject {
    var pointAddress: UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(self).toOpaque()
    }

    var jsonString: String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        } catch let err {
            assertionFailure(err.localizedDescription)
            return nil
        }
    }

    /// 类实例方法交换
    ///   - targetSel: 目标方法
    ///   - newSel: 替换方法
    @discardableResult
    static func exchangeMethod(targetSel: Selector, newSel: Selector) -> Bool {
        guard let before: Method = class_getInstanceMethod(self, targetSel),
              let after: Method = class_getInstanceMethod(self, newSel)
        else {
            return false
        }

        if class_addMethod(self, targetSel, method_getImplementation(after), method_getTypeEncoding(after)) {
            class_replaceMethod(self, newSel, method_getImplementation(before), method_getTypeEncoding(before))
        } else {
            method_exchangeImplementations(before, after)
        }
        return true
    }

    static func className(hasSpace: Bool = false) -> String {
        let name = NSStringFromClass(self)
        if hasSpace {
            return name
        }
        if let last = name.split(separator: ".").last {
            return String(last)
        }
        return ""
    }
}
