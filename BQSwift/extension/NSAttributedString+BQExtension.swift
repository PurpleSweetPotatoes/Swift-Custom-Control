// *******************************************
//  File Name:      NSAttributedString+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/8/21 9:06 AM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

typealias AttributesKey = NSAttributedString.Key

extension NSAttributedString {
    convenience init(string: String, font: UIFont? = nil, textColor: UIColor? = nil) {
        let textInfo = BQTextAttributes()
        textInfo.font = font
        textInfo.textColor = textColor
        self.init(string: string, textInfo: textInfo)
    }

    convenience init(string: String, textInfo: BQTextAttributes) {
        self.init(string: string as String, attributes: textInfo.dictionary)
    }

    convenience init(image: UIImage, font: UIFont = .systemFont(ofSize: 16), space: CGFloat = 0) {
        let attach = NSTextAttachment()
        attach.image = image
        let imgH = font.pointSize
        let imgW = (image.size.width / image.size.height) * imgH
        let textPaddingTop = (font.lineHeight - font.pointSize) / 2
        attach.bounds = CGRect(x: 0, y: -textPaddingTop - space, width: imgW, height: imgH)
        self.init(attachment: attach)
    }
}

public final class BQTextAttributes {
    fileprivate(set) var dictionary: [AttributesKey: Any] = [:]

    // MARK: - creat

    init() {
        dictionary[AttributesKey.paragraphStyle] = paragraphStyle
        paragraphStyle.lineBreakMode = .byCharWrapping
    }

    init(base: BQTextAttributes) {
        dictionary = base.dictionary
        let clone = NSMutableParagraphStyle()
        clone.setParagraphStyle(base.paragraphStyle)
        paragraphStyle = clone
        dictionary[AttributesKey.paragraphStyle] = paragraphStyle
    }

    // MARK: - font 字体

    public var font: UIFont? {
        get {
            return dictionary[AttributesKey.font] as? UIFont
        }
        set {
            dictionary[AttributesKey.font] = newValue
        }
    }

    @discardableResult
    public func font(_ font: UIFont?) -> Self {
        self.font = font
        return self
    }

    @discardableResult
    public func font(name: String, size: CGFloat) -> Self {
        return font(UIFont(name: name, size: size))
    }

    // MARK: - textColor 文字颜色

    public var textColor: UIColor? {
        get {
            return dictionary[AttributesKey.foregroundColor] as? UIColor
        }
        set {
            dictionary[AttributesKey.foregroundColor] = newValue
        }
    }

    @discardableResult
    public func textColor(_ color: UIColor?) -> Self {
        textColor = color
        return self
    }

    // MARK: - backgroundColor 文字颜色

    public var backgroundColor: UIColor? {
        get {
            return dictionary[AttributesKey.backgroundColor] as? UIColor
        }
        set {
            dictionary[AttributesKey.backgroundColor] = newValue
        }
    }

    @discardableResult
    public func backgroundColor(_ color: UIColor?) -> Self {
        backgroundColor = color
        return self
    }

    // MARK: - paragraphStyle 段落样式

    public var paragraphStyle = NSMutableParagraphStyle() {
        didSet {
            dictionary[AttributesKey.paragraphStyle] = paragraphStyle
        }
    }

    @discardableResult
    public func paragraphStyle(_ style: NSMutableParagraphStyle) -> Self {
        paragraphStyle = style
        return self
    }

    // MARK: - lineSpacing 行间距

    public var lineSpacing: CGFloat {
        get { return paragraphStyle.lineSpacing }
        set { paragraphStyle.lineSpacing = CGFloat(newValue) }
    }

    @discardableResult
    public func lineSpacing(_ value: CGFloat) -> Self {
        lineSpacing = value
        return self
    }

    // MARK: - alignment 对齐方式

    public var alignment: NSTextAlignment {
        get { return paragraphStyle.alignment }
        set { paragraphStyle.alignment = newValue }
    }

    @discardableResult
    public func alignment(_ alignment: NSTextAlignment) -> Self {
        self.alignment = alignment
        return self
    }

    // MARK: - link 链接

    public var link: URL? {
        get {
            return dictionary[AttributesKey.link] as? URL
        }
        set {
            dictionary[AttributesKey.link] = newValue
        }
    }

    @discardableResult
    public func link(_ link: URL?) -> Self {
        self.link = link
        return self
    }

    // MARK: - baselineOffset 基址偏移(正上移，负下移)

    public var baselineOffset: NSNumber? {
        get {
            return dictionary[AttributesKey.baselineOffset] as? NSNumber
        }
        set {
            dictionary[AttributesKey.baselineOffset] = newValue
        }
    }

    @discardableResult
    public func baselineOffset(_ value: Float) -> Self {
        baselineOffset = NSNumber(value: value)
        return self
    }

    // MARK: - obliqueness 字体倾斜度(正右倾，负左倾)

    public var obliqueness: NSNumber? {
        get {
            return dictionary[AttributesKey.obliqueness] as? NSNumber
        }
        set {
            dictionary[AttributesKey.obliqueness] = newValue
        }
    }

    @discardableResult
    public func obliqueness(_ value: Float) -> Self {
        obliqueness = NSNumber(value: value)
        return self
    }

    // MARK: - kern 字间距

    public var kern: NSNumber? {
        get {
            return dictionary[AttributesKey.kern] as? NSNumber
        }
        set {
            dictionary[AttributesKey.kern] = newValue
        }
    }

    @discardableResult
    public func kern(_ value: Float) -> Self {
        kern = NSNumber(value: value)
        return self
    }

    // MARK: - strokeColor 文字边框颜色配合strokeWidth使用

    public var strokeColor: UIColor? {
        get {
            return dictionary[AttributesKey.strokeColor] as? UIColor
        }
        set {
            dictionary[AttributesKey.strokeColor] = newValue
        }
    }

    @discardableResult
    public func strokeColor(_ color: UIColor?) -> Self {
        strokeColor = color
        return self
    }

    // MARK: - strokeWidth 文字边框宽度

    public var strokeWidth: NSNumber? {
        get {
            return dictionary[AttributesKey.strokeWidth] as? NSNumber
        }
        set {
            dictionary[AttributesKey.strokeWidth] = newValue
        }
    }

    @discardableResult
    public func strokeWidth(_ value: Float) -> Self {
        strokeWidth = NSNumber(value: value)
        return self
    }

    // MARK: - underlineStyle 下划线类型

    public var underlineStyle: NSNumber? {
        get {
            return dictionary[AttributesKey.underlineStyle] as? NSNumber
        }
        set {
            dictionary[AttributesKey.underlineStyle] = newValue
        }
    }

    @discardableResult
    public func underlineStyle(_ style: NSUnderlineStyle) -> Self {
        underlineStyle = NSNumber(value: style.rawValue)
        return self
    }

    // MARK: - underlineColor 下划线类型

    public var underlineColor: UIColor? {
        get {
            return dictionary[AttributesKey.underlineColor] as? UIColor
        }
        set {
            dictionary[AttributesKey.underlineColor] = newValue
        }
    }

    @discardableResult
    public func underlineColor(_ color: UIColor?) -> Self {
        underlineColor = color
        return self
    }

    // MARK: - deleteStyle 删除线

    public var deleteStyle: NSNumber? {
        get {
            return dictionary[AttributesKey.strikethroughStyle] as? NSNumber
        }
        set {
            dictionary[AttributesKey.strikethroughStyle] = newValue
        }
    }

    @discardableResult
    public func deleteStyle(_ value: Float) -> Self {
        deleteStyle = NSNumber(value: value)
        return self
    }

    // MARK: - deleteStyleColor 删除线颜色

    public var deleteStyleColor: UIColor? {
        get {
            return dictionary[AttributesKey.strikethroughColor] as? UIColor
        }
        set {
            dictionary[AttributesKey.strikethroughColor] = newValue
        }
    }

    @discardableResult
    public func deleteStyleColor(_ color: UIColor) -> Self {
        deleteStyleColor = color
        return self
    }
}
