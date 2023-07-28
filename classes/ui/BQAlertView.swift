// *******************************************
//  File Name:      BQAlertView.swift       
//  Author:         MrBai
//  Created Date:   2022/2/23 11:05 AM
//    
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit

public typealias BQAlertBtnBlock = (Int) -> Void

public struct BQAlertAction {
    let name: String
    let color: UIColor
    let font: UIFont
    
    public init(name btnName: String, color btnColor: UIColor = .black, font btnFont: UIFont = .systemFont(ofSize: 15)) {
        name = btnName
        color = btnColor
        font = btnFont
    }
}

/// 利用建造者模式设计弹窗
/// 保证弹窗所需元素配置完成后进行展示
/// 用法示例:
/// priority代表弹窗优先级，数字越小 优先级约高
/// BQAlertView.alert().title("测试").content("这是第个弹窗").priority(1).show()
public class BQAlertView: UIView {
    
    // MARK: - *** public
    
    public var priority: Int {
        return config.priority
    }
    
    final public class BQAlertConfig {
        var priority: Int = 100
        var bgView: UIView?
        var title: String = ""
        var content: String = ""
        var attributContent = NSAttributedString()
        var actions = [BQAlertAction(name: "确认", color: UIColor(0x0099ff))]
        var handle: BQAlertBtnBlock?
        fileprivate weak var supView: UIView? = UIApplication.keyWindow
        
        @discardableResult
        public func title(_ str: String) -> Self {
            title = str
            return self
        }
        
        /// 优先级 数字约小越先展示
        /// - Parameter priority: 优先级别
        @discardableResult
        public func priority(_ num: Int) -> Self {
            priority = num
            return self
        }
        
        @discardableResult
        public func content(_ str: String = "", attribute: NSAttributedString = NSAttributedString()) -> Self {
            content = str
            attributContent = attribute
            return self
        }
        
        @discardableResult
        public func actions(_ btns: [BQAlertAction]) -> Self {
            actions = btns
            return self
        }
        
        @discardableResult
        public func actionBlock(_ block: @escaping BQAlertBtnBlock) -> Self {
            handle = block
            return self
        }
        
        @discardableResult
        public func supView(_ view: UIView) -> Self {
            supView = view
            return self
        }
        
        private func configCheck() {
            if let _ = bgView {
                return
            }
            
            assert(content.count > 0 || attributContent.length > 0, "内容不能为空")
            assert(actions.count > 0, "回调按钮不能为空")
        }
        
        @discardableResult
        public func show() -> BQAlertView {
            configCheck()
            let alertV = BQAlertView(frame: supView!.bounds, info: self)
            BQAlertViewManager.addAlertInfo(v: alertV)
            return alertV
        }
    }
    
    deinit {
        BQAlertViewManager.showInfo = nil
        BQAlertViewManager.showNext()
    }
    
    /// 配置文件
    fileprivate var config: BQAlertConfig!
    private var bgV: UIView!
    private let space: CGFloat = 15
    
    @discardableResult
    static public func alert() -> BQAlertConfig {
        return BQAlertConfig()
    }
    
    convenience public init(frame: CGRect, info: BQAlertConfig) {
        self.init(frame: frame)
        config = info
        configUI()
    }
    
    private func configUI() {
        backgroundColor = UIColor(white: 0, alpha: 0.6)
        if let v = config.bgView {
            bgV = v
        } else {
            bgV = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 100))
            bgV.backgroundColor = .white
            bgV.corner(8)
            configAlertView()
        }
        
        addSubview(bgV)
    }
    
    private func configAlertView() {
        var top: CGFloat = 15
        
        top = createTitleLab(top: top)
        top = createContentLab(top: top)
        // 分割线
        bgV.layer.addSublayer(CALayer.lineLayer(frame: CGRect(x: 0, y: top, width: bgV.sizeW, height: 1)))
        top += 1
        // 按钮
        bgV.sizeH = createBtns(top: top)
        bgV.center = CGPoint(x: sizeW * 0.5, y: sizeH * 0.5)
        
    }
    
    private func createTitleLab(top: CGFloat) -> CGFloat {
        if config.title.count > 0 {
            let lab = UILabel(frame: CGRect(x: space, y: top, width: bgV.sizeW - space * 2, height: 20), font: .systemFont(ofSize: 17, weight: .semibold), alignment: .center)
            lab.text = config.title
            lab.adjustHeight()
            bgV.addSubview(lab)
            return lab.bottom + space
        }
        return top
    }
    
    private func createContentLab(top: CGFloat) -> CGFloat {
        let contentLab = UILabel(frame: CGRect(x: space, y: top, width: bgV.sizeW - space * 2, height: 20), font: .systemFont(ofSize: 15), alignment: .center)
        contentLab.numberOfLines = 0
        if config.attributContent.length > 0 {
            contentLab.attributedText = config.attributContent
            contentLab.adjustHeight(isAttribute: true)
        } else {
            contentLab.text = config.content
            contentLab.adjustHeight()
        }
        bgV.addSubview(contentLab)
        return contentLab.bottom + 15
    }
    
    private func createBtns(top: CGFloat) -> CGFloat {
        let btnW = bgV.sizeW / CGFloat(config.actions.count)
        for (index, action) in config.actions.enumerated() {
            let btn = UIButton(type: .custom)
            btn.tag = index
            btn.setTitle(action.name, for: .normal)
            btn.setTitleColor(action.color, for: .normal)
            btn.titleLabel?.font = action.font
            btn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
            if index != 0 {
                btn.layer.addSublayer(CALayer.lineLayer(frame: CGRect(x: 0, y: 2, width: 1, height: 40 - 4)))
            }
            btn.frame = CGRect(x: CGFloat(index) * btnW, y: top, width: btnW, height: 40)
            bgV.addSubview(btn)
        }
        return top + 40
    }
    
    fileprivate func startAnimation() {
        if let _ = config.bgView {
            
        } else {
            bgV.alpha = 0
            bgV.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.bgV.alpha = 1
                self?.bgV.transform = CGAffineTransform.identity
            }
        }
        
    }
    
    func removeAnimation() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.alpha = 0
        } completion: { flag in
            self.removeFromSuperview()
        }
    }
    
    @objc private func btnClick(sender: UIButton) {
        if let block = config.handle {
            block(sender.tag)
        }
        removeFromSuperview()
//        self.removeAnimation()
    }
}

enum BQAlertViewManager {
    
    static weak var showInfo: BQAlertView?
    
    static var alertList = [BQAlertView]()

    static func addAlertInfo(v: BQAlertView) {
        alertList.append(v)
        alertList.sort { $0.priority < $1.priority }
        BQAlertViewManager.showNext()
    }
    
    static func showNext() {
        if let _ = showInfo {
            return
        }
        
        if let info = alertList.first {
            showInfo = info
            info.config.supView?.addSubview(info)
            info.startAnimation()
            alertList.remove(at: 0)
        } else {
            BQLogger.debug("队列资源展示完毕")
        }
    }
}
