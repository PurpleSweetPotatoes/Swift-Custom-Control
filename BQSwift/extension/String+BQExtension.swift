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
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue) else {
            return false
        }
        return detector.numberOfMatches(in: self, range: NSRange(location: 0, length: self.count)) > 0
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
    
    public func toDictionary() -> [String: Any] {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            } catch {
                return [String: Any]()
            }
        }
        return [String: Any]()
    }
    
    public func urlEncode() -> String? {
        if self.hasChinese() {
            var set = CharacterSet.urlQueryAllowed
            set.insert(charactersIn: "#")
            return self.addingPercentEncoding(withAllowedCharacters: set)
        }
        return self
    }
    
    public func htmlAttributeStr(fontName: String = "Heiti SC", fontSize: Int = 14, colorHex: String = "000000") -> NSAttributedString? {
        do {
            let cssPrefix = "<style>* { font-family: \(fontName); color: #\(colorHex); font-size: \(fontSize); }</style>"
            let html = cssPrefix + self
            guard let data = html.data(using: String.Encoding.utf8) else {  return nil }
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    /// 将中文字符串转换为拼音
    ///
    /// - Parameter hasBlank: 是否带空格（默认不带空格）
    public func transformToPinyin(hasBlank: Bool = false) -> String {
        
        let stringRef = NSMutableString(string: self) as CFMutableString
        CFStringTransform(stringRef,nil, kCFStringTransformToLatin, false) // 转换为带音标的拼音
        CFStringTransform(stringRef, nil, kCFStringTransformStripCombiningMarks, false) // 去掉音标
        let pinyin = stringRef as String
        return hasBlank ? pinyin : pinyin.replacingOccurrences(of: " ", with: "")
    }
    
    /// 获取中文首字母
    ///
    /// - Parameter lowercased: 是否小写（默认小写）
    public func transformToPinyinHead(lowercased: Bool = true) -> String {
        let pinyin = transformToPinyin(hasBlank: true).capitalized // 字符串转换为首字母大写
        var headPinyinStr = ""
        for (_, ch) in pinyin.enumerated() {
            if ch <= "Z" && ch >= "A" {
                headPinyinStr.append(ch) // 获取所有大写字母
            }
        }
        return lowercased ? headPinyinStr.lowercased() : headPinyinStr
    }
    
    public subscript(range: NSRange) -> String {
        get {
            if range.location < 0 || range.location + range.length >= self.count {
                return ""
            }
            let start = self.index(self.startIndex, offsetBy: range.location)
            let end = self.index(self.startIndex, offsetBy: range.location + range.length)
            return String(self[start..<end])
        }
    }
    
    public subscript(range:ClosedRange<Int>) -> String {
        get {
            if range.lowerBound < 0 || range.upperBound > self.count {
                return "index is not in bound"
            }
            let start = self.index(self.startIndex, offsetBy: range.lowerBound)
            let end = self.index(self.startIndex, offsetBy: range.upperBound)
            return String(self[start..<end])
        }
    }
    
    public subscript(index: Int) -> Character {
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
