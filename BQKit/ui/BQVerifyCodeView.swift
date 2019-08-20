// *******************************************
//  File Name:      BQVerifyCodeView.swift       
//  Author:         MrBai
//  Created Date:   2019/8/19 2:24 PM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************
    

import UIKit

class BQVerifyCodeView: UIView {

    // MARK: - var
    private var verCode: String = ""
    private var codeNum: Int = 0
    private var disturbLineNum: Int = 0
    private var fontSize: CGFloat = 0
    var textColor: UIColor?
    /// 是否区分大小写
    var checkStrict = false
    // MARK: - creat

    init(frame: CGRect, fontSize: CGFloat = 20, codeNum: Int = 4, disturbLineNum: Int = 5) {
        super.init(frame: frame)
        self.codeNum = codeNum
        self.disturbLineNum = disturbLineNum
        self.fontSize = fontSize
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - public method
    
    public func verify(str:String) -> Bool {
        if self.checkStrict {
            return str == self.verCode
        }
        return str.uppercased() == self.verCode.uppercased()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.setNeedsDisplay()
    }
    
    // MARK: - private method
    
    private func randomPoint() -> CGPoint {
        let x = CGFloat(arc4random_uniform(UInt32(self.bounds.size.width)))
        let y = CGFloat(arc4random_uniform(UInt32(self.bounds.size.height)))
        return CGPoint(x: x, y: y)
    }
    
    // MARK: - UI method
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.verCode = ""
        let charArr = ["0", "1","2","3","4","5","6","7","8","9","a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        let context = UIGraphicsGetCurrentContext()!
        context.clear(rect)
        context.setFillColor(self.backgroundColor?.cgColor ?? UIColor.randomColor.cgColor)
        context.fill(rect)
        
        //填字
        let charWidth = rect.width / CGFloat(self.codeNum)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        var attrs = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: self.fontSize),
            NSAttributedString.Key.paragraphStyle: paragraphStyle]

        for i in 0 ..< self.codeNum {
            let index = Int(arc4random_uniform(UInt32(charArr.count)))
            let code = charArr[index]
            attrs[NSAttributedString.Key.foregroundColor] = self.textColor ?? UIColor.randomColor
            code.draw(at: CGPoint(x: charWidth * CGFloat(i) + (charWidth - self.fontSize) * 0.5, y: (rect.height - self.fontSize) * 0.5), withAttributes: attrs)
            self.verCode += code
        }
        
        //划线
        context.setLineWidth(1)
        for _ in 0 ..< self.disturbLineNum {
            context.setStrokeColor(UIColor.randomColor.cgColor)
            context.move(to: self.randomPoint())
            context.addLine(to: self.randomPoint())
            context.strokePath()
        }
    }
}
