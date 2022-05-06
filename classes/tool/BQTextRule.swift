// *******************************************
//  File Name:      BQTextRule.swift
//  Author:         MrBai
//  Created Date:   2020/5/14 4:10 PM
//
//  Copyright © 2020 baiqiang
//  All rights reserved
// *******************************************

import UIKit


/// 输入内容
public enum BQTextType: Int {
    /// 无规则
    case normal
    /// 数字
    case num
    /// 字母
    case char
    /// 汉字
    case chinese
    /// 数字+字母
    case numChar
    /// 数字+小数点
    case price
}

public struct BQTextRule {
    var type: BQTextType
    var maxLength: UInt
    var maxNum: Int = 100000
    var minNUm: Int = -100000
    var precision: (UInt, UInt)?
    var upText: Bool
    var clearSpace: Bool

    public init(type: BQTextType = .normal, maxLength: UInt = 1000, precision: (UInt, UInt)? = nil, upText: Bool = false, clearSpace: Bool = false) {
        self.type = type
        self.maxLength = maxLength
        self.precision = precision
        self.upText = upText
        self.clearSpace = clearSpace
    }
}

public extension UITextField {
    @objc func tfValueDidChange() {
        guard var content = text, let rule = self.rule else {
            return
        }

        switch rule.type {
        case .num:
            content = content.deleteCharset(regular: "[^0-9]")
            if let number = Int(content) {
                if rule.maxNum < number {
                    content = String(rule.maxNum)
                } else if rule.minNUm > number {
                    content = String(rule.minNUm)
                } else {
                    content = String(number)
                }
            }
        case .char:
            content = content.deleteCharset(regular: "[^a-zA-Z]")
        case .numChar:
            content = content.deleteCharset(regular: "[^a-zA-Z0-9]")
        case .chinese:
            content = content.deleteCharset(regular: "[^\\u4e00-\\u9fa5]")
        case .price:
            content = content.deleteCharset(regular: "[^0-9\\.]")
            if let (left, right) = rule.precision {
                text = reservePrice(content: content, left: left, right: right)
                return
            }
        default:
            break
        }

        if rule.clearSpace {
            content = content.replacingOccurrences(of: " ", with: "")
        }

        if rule.upText {
            content = content.uppercased()
        }

        if content.count > rule.maxLength {
            content = content[NSRange(location: 0, length: Int(rule.maxLength))]
        }
        text = content
    }

    func reservePrice(content: String, left: UInt, right: UInt) -> String {
        if content.hasPrefix(".") {
            return "0."
        }

        let arr = content.utf8CString
        var outArr = [CChar]()
        var hasPoint = false
        var leftNum = 0
        var rightNum = 0

        for char in arr {
            if char >= 48, char <= 57 {
                if !hasPoint, leftNum < left { // 实部
                    if outArr.count == 0, char == 48 {
                        continue
                    }
                    leftNum += 1
                    outArr.append(char)
                } else if hasPoint, rightNum < right { // 虚部
                    rightNum += 1
                    outArr.append(char)
                    if rightNum == right {
                        break
                    }
                }
            } else if char == 46 { // 小数点
                hasPoint = true
                if outArr.count == 0 {
                    outArr.append(48)
                }
                outArr.append(char)
            }
        }

        // 添加结束符
        outArr.append(0)
        return String(cString: outArr)
    }

    private enum AssociatedKeys {
        static var ruleKey: Void?
    }

    var rule:BQTextRule? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ruleKey) as? BQTextRule
        }
        set {
            
            if newValue == nil && rule != nil {
                removeTarget(self, action: #selector(tfValueDidChange), for: .editingChanged)
            } else if rule == nil && newValue != nil {
                addTarget(self, action: #selector(tfValueDidChange), for: .editingChanged)
            }
            
            if let rule = newValue {
                if let _ = rule.precision, rule.type == .price {
                    keyboardType = .decimalPad
                } else if rule.type == .num {
                    keyboardType = .numberPad
                } else if rule.type == .char {
                    keyboardType = .asciiCapable
                } else {
                    keyboardType = .default
                }
            }

            objc_setAssociatedObject(self, &AssociatedKeys.ruleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        }
    }
}
