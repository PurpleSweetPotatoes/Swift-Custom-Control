// *******************************************
//  File Name:      BQAlertView.swift       
//  Author:         MrBai
//  Created Date:   2022/2/23 11:05 AM
//    
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit

typealias BQAlertBtnBlock = (Int) -> Void

struct BQAlertAction {
    let name: String
    let color: UIColor
    let font: UIFont
    init(name btnName: String, color btnColor: UIColor = .black, font btnFont: UIFont = .systemFont(ofSize: 15)) {
        name = btnName
        color = btnColor
        font = btnFont
    }
}

class BQAlertView: UIView, BQAlertViewProtocol {
    
    // MARK: - *** public
    
    @discardableResult
    static func alert() -> BQAlertView {
        return BQAlertView(frame: UIScreen.main.bounds)
    }
    
    @discardableResult
    func title(_ title: String) -> Self {
        
        if titleLab == nil {
            let lab = UILabel(frame: CGRect(x: 15, y: 15, width: disV.sizeW - 30, height: 20), font: .systemFont(ofSize: 17, weight: .semibold), alignment: .center)
            disV.addSubview(lab)
            titleLab = lab
        }
        
        if let lab = titleLab {
            lab.text = title
            lab.adjustHeight()
        }
        
        return self
    }
    
    @discardableResult
    func text(_ text: String) -> Self {
        
        creatTextLab()
        
        if let lab = textLab {
            lab.text = text
            lab.adjustHeight()
        }
        
        return self
    }
    
    @discardableResult
    func attributedText(_ attributedText: NSAttributedString) -> Self {
        
        creatTextLab()
        
        if let lab = textLab {
            lab.attributedText = attributedText
            lab.adjustHeight(isAttribute: true)
        }
        
        return self
    }
    
    /// 优先级 数字约小越先展示
    /// - Parameter priority: 优先级别
    @discardableResult
    func priority(_ priority: Int) -> Self {
        self.priority = priority
        return self;
    }
    
    // MARK: - *** parivate var
    var priority: Int = 100
    var disV = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 100))
    var frameTop : CGFloat = 20.0
    var titleLab: UILabel?
    var textLab: UILabel?
    var btnArr = [UIButton]()
    var btnBlock : BQAlertBtnBlock?
    var isCustom = false
    
    // MARK: - *** init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0, alpha: 0.6)
        disV.corner(8).backgroundColor(.white)
        addSubview(disV)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - *** UI
    func creatTextLab() {
        if textLab == nil {
            let lab = UILabel(frame: CGRect(x: frameTop, y: frameTop, width: disV.sizeW - frameTop * 2, height: 20), font: .systemFont(ofSize: 15), alignment: .center)
            lab.numberOfLines = 0
            disV.addSubview(lab)
            textLab = lab
        }
    }
    
    func adjustFrame() {
        
        if isCustom { // 自定义不处理
            return
        }
        
        if let lab = titleLab {
            frameTop = lab.bottom + 8
        } else {
            frameTop = 20
        }
        
        if let lab = textLab {
            lab.top = frameTop
            frameTop = lab.bottom + 20
        }
        
        if btnArr.count == 0 {
            addActions(actions: BQAlertAction(name: "确认", color: UIColor.mainColor))
        }
        
        disV.layer.addSublayer(CALayer.lineLayer(frame: CGRect(x: 0, y: frameTop, width: disV.sizeW, height: 1)))
        
        let btnW = disV.sizeW / CGFloat(btnArr.count)
        for (index, btn) in btnArr.enumerated() {
            btn.frame = CGRect(x: CGFloat(index) * btnW, y: frameTop, width: btnW, height: 40)
            if index == btnArr.count - 1 {
                frameTop = btn.bottom
            }
        }
        
        disV.sizeH(frameTop).center = CGPoint(x: sizeW * 0.5, y: sizeH * 0.5)
    }
    
    @discardableResult
    func addActions(actions: BQAlertAction ..., block: BQAlertBtnBlock? = nil) -> Self {
        for (index, action) in actions.enumerated() {
            let btn = UIButton(type: .custom)
            btn.tag = index
            btn.setTitle(action.name, for: .normal)
            btn.setTitleColor(action.color, for: .normal)
            btn.titleLabel?.font = action.font
            btn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
            if index != 0 {
                btn.layer.addSublayer(CALayer.lineLayer(frame: CGRect(x: 0, y: 2, width: 1, height: 40 - 4)))
            }
            disV.addSubview(btn)
            btnArr.append(btn)
        }
        btnBlock = block
        return self
    }
    
    @objc func btnClick(sender: UIButton) {
        if let block = btnBlock {
            block(sender.tag)
        }
        removeFromSuperview()
        didRemoveSelf()
    }
    
    @discardableResult
    func show(supV: UIView? = UIApplication.shared.keyWindow) -> BQAlertView {
        if let sup = supV {
            adjustFrame()
            BQAlertViewManager.addAlertInfo(v: self, supV: sup)
        }
        return self
    }
    
}
