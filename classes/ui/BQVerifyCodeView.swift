// *******************************************
//  File Name:      BQVerifyCodeView.swift
//  Author:         MrBai
//  Created Date:   2019/8/19 2:24 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

public final class BQVerifyCodeView: UIView {
    // MARK: - var

    private var verCode: String = ""
    private var codeNum: Int = 0
    private var disturbLineNum: Int = 0
    private var fontSize: CGFloat = 0
    public var textColor: UIColor?
    /// 是否区分大小写
    public var checkStrict = false

    // MARK: - creat

    public init(frame: CGRect, fontSize: CGFloat = 20, codeNum: Int = 4, disturbLineNum: Int = 5) {
        super.init(frame: frame)
        self.codeNum = codeNum
        self.disturbLineNum = disturbLineNum
        self.fontSize = fontSize
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - public method

    public func verify(str: String) -> Bool {
        if checkStrict {
            return str == verCode
        }
        return str.uppercased() == verCode.uppercased()
    }

    override public func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        setNeedsDisplay()
    }

    // MARK: - private method

    private func randomPoint() -> CGPoint {
        let x = CGFloat(arc4random_uniform(UInt32(bounds.size.width)))
        let y = CGFloat(arc4random_uniform(UInt32(bounds.size.height)))
        return CGPoint(x: x, y: y)
    }

    // MARK: - UI method

    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        verCode = ""
        let charArr = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        let context = UIGraphicsGetCurrentContext()!
        context.clear(rect)
        context.setFillColor(backgroundColor?.cgColor ?? UIColor.randomColor.cgColor)
        context.fill(rect)

        // 填字
        let charWidth = rect.width / CGFloat(codeNum)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        var attrs = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize),
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
        ]

        for i in 0 ..< codeNum {
            let index = Int(arc4random_uniform(UInt32(charArr.count)))
            let code = charArr[index]
            attrs[NSAttributedString.Key.foregroundColor] = textColor ?? UIColor.randomColor
            code.draw(at: CGPoint(x: charWidth * CGFloat(i) + (charWidth - fontSize) * 0.5, y: (rect.height - fontSize) * 0.5), withAttributes: attrs)
            verCode += code
        }

        // 划线
        context.setLineWidth(1)
        for _ in 0 ..< disturbLineNum {
            context.setStrokeColor(UIColor.randomColor.cgColor)
            context.move(to: randomPoint())
            context.addLine(to: randomPoint())
            context.strokePath()
        }
    }
}
