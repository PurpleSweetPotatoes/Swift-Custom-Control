// *******************************************
//  File Name:      String+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/8/15 2:13 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import Foundation

private var Regular_Phone = "^(13|14|15|17|18)\\d{9}$"
private var Regular_Email = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
private var Regular_CardId = "^((1[1-5])|(2[1-3])|(3[1-7])|(4[1-6])|(5[0-4])|(6[1-5])|71|(8[12])|91)\\d{4}((19\\d{2}(0[13-9]|1[012])(0[1-9]|[12]\\d|30))|(19\\d{2}(0[13578]|1[02])31)|(19\\d{2}02(0[1-9]|1\\d|2[0-8]))|(19([13579][26]|[2468][048]|0[48])0229))\\d{3}(\\d|X|x)?$"
private var Regular_IPAdrress = "^\\d{0,3}\\.\\d{0,3}.\\d{0,3}.\\d{0,3}$"
private var Regular_hasChinese = "[\\u4e00-\\u9fa5]"

public extension String {
    func isPhone() -> Bool {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue) else {
            return false
        }
        return detector.numberOfMatches(in: self, range: NSRange(location: 0, length: count)) > 0
    }

    func isEmail() -> Bool {
        return self.reMatch(Regular_Email)
    }

    func isCard() -> Bool {
        return self.reMatch(Regular_CardId)
    }

    func isIPAddress() -> Bool {
        return self.reMatch(Regular_IPAdrress)
    }

    func hasChinese() -> Bool {
        return self.reMatch(Regular_hasChinese)
    }

    /// 密码判断不包含空格和汉字
    func isPwd() -> Bool {
        if !contains(" ") {
            return self.hasChinese()
        }
        return false
    }

    func reMatch(_ re: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: re, options: .caseInsensitive)
            let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            return matches.count > 0
        } catch {
            return false
        }
    }

    func deleteCharset(regular: String) -> String {
        if count > 0, regular.count > 0 {
            if let express = try? NSRegularExpression(pattern: regular, options: .caseInsensitive) {
                return express.stringByReplacingMatches(in: self, options: .reportProgress, range: NSRange(location: 0, length: count), withTemplate: "")
            }
        }
        return ""
    }

    func toDictionary() -> [String: Any] {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            } catch {
                return [String: Any]()
            }
        }
        return [String: Any]()
    }

    func urlEncode() -> String? {
        let set = CharacterSet(charactersIn: "\"<>@[\\]^`{|}").inverted
        return addingPercentEncoding(withAllowedCharacters: set)
    }

    func htmlAttributeStr(fontName: String = "Heiti SC", fontSize: Int = 14, colorHex: String = "000000") -> NSAttributedString? {
        do {
            let cssPrefix = "<style>* { font-family: \(fontName); color: #\(colorHex); font-size: \(fontSize); }</style>"
            let html = cssPrefix + self
            guard let data = html.data(using: String.Encoding.utf8) else { return nil }
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }

    var hexData: Data? {
        var data = Data(capacity: self.count / 2)

        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }

        guard data.count > 0 else { return nil }

        return data
    }

    var lastPathComponent: String {
        guard let last = split(separator: "/").last else { return self }
        return String(last)
    }

    var lastPathComponentName: String {
        guard let last = split(separator: "/").last, let name = last.split(separator: ".").first else { return self }
        return String(name)
    }

    static var documentPath: String {
        return "\(NSHomeDirectory())/Documents"
    }

    /// 将中文字符串转换为拼音
    ///
    /// - Parameter hasBlank: 是否带空格（默认不带空格）
    func transformToPinyin(hasBlank: Bool = false) -> String {
        let stringRef = NSMutableString(string: self) as CFMutableString
        CFStringTransform(stringRef, nil, kCFStringTransformToLatin, false) // 转换为带音标的拼音
        CFStringTransform(stringRef, nil, kCFStringTransformStripCombiningMarks, false) // 去掉音标
        let pinyin = stringRef as String
        return hasBlank ? pinyin : pinyin.replacingOccurrences(of: " ", with: "")
    }

    /// 获取中文首字母
    ///
    /// - Parameter lowercased: 是否小写（默认小写）
    func transformToPinyinHead(lowercased: Bool = true) -> String {
        let pinyin = self.transformToPinyin(hasBlank: true).capitalized // 字符串转换为首字母大写
        var headPinyinStr = ""
        for (_, ch) in pinyin.enumerated() {
            if ch <= "Z", ch >= "A" {
                headPinyinStr.append(ch) // 获取所有大写字母
            }
        }
        return lowercased ? headPinyinStr.lowercased() : headPinyinStr
    }

    func toDate(format: String = "yyyy/MM/dd") -> Date? {
        return Date.load(self, format: format)
    }

    mutating func insert(_ str: String, local: Int) {
        let at = index(startIndex, offsetBy: local)
        self.insert(Character(str), at: at)
    }

    /// 增加小数点，针对整形转小数
    /// - Parameter decimal: 后两位变小数点
    /// - Returns: 转化后小数字符串
    func toFloatStr(_ deci: Int = 2) -> String {
        if let num = Int(self), deci > 0 {
            var last = num
            var outStr = ""
            for i in (0 ... deci).reversed() {
                let deciNum = Int(pow(Double(10.0), Double(i)))
                outStr.append("\(last / deciNum)")
                last = last % deciNum
            }
            return outStr
        }
        return ""
    }

    func numberOfLines(with width: CGFloat, font: UIFont = .systemFont(ofSize: 17)) -> Int {
        let attribute = NSAttributedString(string: self, font: font)
        return attribute.numberOfLines(with: width)
    }

    subscript(range: NSRange) -> String {
        if range.location < 0 || range.location + range.length >= count {
            return ""
        }
        let start = index(startIndex, offsetBy: range.location)
        let end = index(startIndex, offsetBy: range.location + range.length)
        return String(self[start ..< end])
    }

    subscript(range: ClosedRange<Int>) -> String {
        if range.lowerBound < 0 || range.upperBound > count {
            return "index is not in bound"
        }
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return String(self[start ..< end])
    }

    subscript(index: Int) -> Character {
        get {
            return self[self.index(startIndex, offsetBy: index)]
        }
        set {
            let rangeIndex = self.index(startIndex, offsetBy: index)
            replaceSubrange(rangeIndex ... rangeIndex, with: String(newValue))
        }
    }
}

extension Character {
    func toInt() -> Int {
        var intFromCharacter = 0
        for scalar in String(self).unicodeScalars {
            intFromCharacter = Int(scalar.value)
        }
        return intFromCharacter
    }
}
