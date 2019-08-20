// *******************************************
//  File Name:      String+BQExtension.swift       
//  Author:         MrBai
//  Created Date:   2019/8/15 2:13 PM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************
    

import Foundation

infix operator =~ : Regular
precedencegroup Regular {
    associativity: left
    higherThan: AdditionPrecedence
    lowerThan: MultiplicationPrecedence
}

private var Regular_Phone = "^(13|14|15|17|18)\\d{9}$"
private var Regular_Email = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
private var Regular_CardId = "^((1[1-5])|(2[1-3])|(3[1-7])|(4[1-6])|(5[0-4])|(6[1-5])|71|(8[12])|91)\\d{4}((19\\d{2}(0[13-9]|1[012])(0[1-9]|[12]\\d|30))|(19\\d{2}(0[13578]|1[02])31)|(19\\d{2}02(0[1-9]|1\\d|2[0-8]))|(19([13579][26]|[2468][048]|0[48])0229))\\d{3}(\\d|X|x)?$"
private var Regular_IPAdrress = "^\\d{0,3}\\.\\d{0,3}.\\d{0,3}.\\d{0,3}$"
private var Regular_hasChinese = "[\\u4e00-\\u9fa5]"

extension String {
    
    public func isPhone() -> Bool {
        return self =~ Regular_Phone
    }
    
    public func isEmail() -> Bool {
        return self =~ Regular_Email
    }
    
    public func isCard() -> Bool {
        return self =~ Regular_CardId
    }
    
    public func isIPAddress() -> Bool{
        return self =~ Regular_IPAdrress
    }
    
    public func hasChinese() -> Bool {
        return self =~ Regular_hasChinese
    }
    
    /// 密码判断不包含空格和汉字
    public func isPwd() -> Bool {
        if !self.contains(" ") {
            return self.hasChinese()
        }
        return false
    }
    
    //正则表达判断,lhs:字符串,rhs:正则式
    static func =~(lhs: String, rhs: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: rhs, options: .caseInsensitive)
            let matches = regex.matches(in: lhs, options: [], range: NSMakeRange(0, lhs.count))
            return matches.count > 0
        } catch {
            return false
        }
    }
    
    func toDictionary() -> [String: Any] {
        var dict = [String: Any]()
        if let data = self.data(using: .utf8) {
            do {
                dict = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return dict
    }
    
    subscript(range: NSRange) -> String {
        get {
            if range.location < 0 || range.location + range.length >= self.count {
                return ""
            }
            let start = self.index(self.startIndex, offsetBy: range.location)
            let end = self.index(self.startIndex, offsetBy: range.location + range.length)
            return String(self[start..<end])
        }
    }
    
    subscript(range:ClosedRange<Int>) -> String {
        get {
            if range.lowerBound < 0 || range.upperBound > self.count {
                return "index is not in bound"
            }
            let start = self.index(self.startIndex, offsetBy: range.lowerBound)
            let end = self.index(self.startIndex, offsetBy: range.upperBound)
            return String(self[start..<end])
        }
    }
    
    subscript(index: Int) -> Character {
        get {
            return self[self.index(startIndex, offsetBy: index)]
        }
        set {
            let rangeIndex = self.index(startIndex, offsetBy: index)
            self.replaceSubrange(rangeIndex...rangeIndex, with: String(newValue))
        }
    }
}

extension Character {
    func toInt() -> Int
    {
        var intFromCharacter:Int = 0
        for scalar in String(self).unicodeScalars
        {
            intFromCharacter = Int(scalar.value)
        }
        return intFromCharacter
    }
}
