//
//  UIButton+extension.swift
//  swift4.2Demo
//
//  Created by baiqiang on 2018/10/6.
//  Copyright © 2018年 baiqiang. All rights reserved.
//

import UIKit

enum BtnSubViewAdjust {
    case none
    case left
    case right
    case imgTopTitleBottom
}


/// 按钮点击间隔时间，防止重复点击
private var _interval: TimeInterval = 1

extension UIButton {
    
    /// 倒计时功能
    ///
    /// - Parameters:
    ///   - startTime: 起始时间
    ///   - reduceTime: 递减时间
    ///   - action: 递减回调方法
    func countDown(startTime: Int, reduceTime: Int,action: @escaping(_ sender: UIButton, _ currentTime: Int) -> Void) {
        
        self.countTime = startTime
        self.action = action
        
        self.timer?.cancel()
        self.timer = DispatchSource.makeTimerSource(queue:DispatchQueue.main)
        self.timer?.schedule(deadline: .now(), repeating: .seconds(reduceTime))
        self.timer?.setEventHandler { [weak self] in
            
            if let actionBlock = self?.action {
                actionBlock(self!, self?.countTime ?? 0)
            }
            
            if self?.countTime == 0 {
                self?.isUserInteractionEnabled = true
                self?.timer?.cancel()
            }
            
            self?.countTime -= reduceTime
        }
        
        self.timer?.resume()
        self.isUserInteractionEnabled = false
    }
    
    /// 调整btn视图和文字位置()
    ///
    ///   - Parameters:
    ///   - spacing: 调整后的间距
    ///   - type: 调整方式BtnSubViewAdjust
    func adjustImageTitle(spacing: CGFloat, type: BtnSubViewAdjust) {
        
        //重置内间距、防止获取视图位置出错
        self.imageEdgeInsets = UIEdgeInsets.zero
        self.titleEdgeInsets = UIEdgeInsets.zero
        
        if type == .none {
            return
        }
        
        guard let imgView = self.imageView, let titleLab = self.titleLabel else {
            print("check you btn have image and text!")
            return
        }
        
        let width = self.frame.width
        var imageLeft: CGFloat = 0
        var imageTop: CGFloat = 0
        var titleLeft: CGFloat = 0
        var titleTop: CGFloat = 0
        var titleRift: CGFloat = 0
        
        if type == .imgTopTitleBottom {
            imageLeft = (width - imgView.frame.width) * 0.5 - imgView.frame.origin.x
            imageTop = spacing - imgView.frame.origin.y
            titleLeft = (width - titleLab.frame.width) * 0.5 - titleLab.frame.origin.x - titleLab.frame.origin.x
            titleTop = spacing * 2 + imgView.frame.height - titleLab.frame.origin.y
            titleRift = -titleLeft - titleLab.frame.origin.x * 2
        } else if type == .left {
            imageLeft = spacing - imgView.frame.origin.x
            titleLeft = spacing * 2 + imgView.frame.width - titleLab.frame.origin.x
            titleRift = -titleLeft
        } else {
            titleLeft = width - titleLab.frame.maxX - spacing
            titleRift = -titleLeft
            imageLeft = width - imgView.right - spacing * 2 - titleLab.frame.width
        }
        
        self.imageEdgeInsets = UIEdgeInsets(top: imageTop, left: imageLeft, bottom: -imageTop, right: -imageLeft)
        self.titleEdgeInsets = UIEdgeInsets(top: titleTop, left: titleLeft, bottom: -titleTop, right: titleRift)
    }
    
    public class func startIntervalAction(interval: TimeInterval) {
        _interval = interval
        DispatchQueue.once(#function) {
            BQTool.exchangeMethod(cls: self, targetSel: #selector(UIButton.sendAction), newSel: #selector(UIButton.re_sendAction))
        }
        
    }
    
    @objc private func re_sendAction(action: Selector, to target: AnyObject?, forEvent event: UIEvent?) {
        if self.isKind(of: UIButton.classForCoder()) {
            if self.isIgnoreEvent {
                return
            } else {
                self.perform(#selector(self.resetIgnoreEvent), with: nil, afterDelay: _interval)
            }
        }
        
        self.isIgnoreEvent = true
        self.re_sendAction(action: action, to: target, forEvent: event)
        
    }
    
    @objc private func resetIgnoreEvent() {
        self.isIgnoreEvent = false;
    }
    
    //MARK:- ***** Override func *****
    
    open override func removeFromSuperview() {
        super.removeFromSuperview()
        self.timer?.cancel()
    }
    
    //MARK:- ***** Associated Object *****
    
    typealias btnUpdateBlock = (_ sender: UIButton, _ currentTime: Int) -> Void
    
    private struct AssociatedKeys {
        static var countKey = "btn_countTime"
        static var timerKey = "btn_sourceTimer"
        static var actionKey = "btn_actionKey"
        static var isIgnoreEventKey = "btn_isIgnoreEventKey"
    }
    
    private var action: btnUpdateBlock? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.actionKey) as? btnUpdateBlock
        }
        set (newValue){
            objc_setAssociatedObject(self, &AssociatedKeys.actionKey, newValue!, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private var timer: DispatchSourceTimer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.timerKey) as? DispatchSourceTimer
        }
        set (newValue){
            objc_setAssociatedObject(self, &AssociatedKeys.timerKey, newValue!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var countTime: Int! {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.countKey) as! Int)
        }
        set (newValue){
            objc_setAssociatedObject(self, &AssociatedKeys.countKey, newValue!, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    private var isIgnoreEvent: Bool! {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.isIgnoreEventKey) as? Bool) ?? false
        }
        set (newValue){
            objc_setAssociatedObject(self, &AssociatedKeys.isIgnoreEventKey, newValue!, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
}
