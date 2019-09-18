// *******************************************
//  File Name:      UIButton+BQExtension.swift       
//  Author:         MrBai
//  Created Date:   2019/8/15 4:15 PM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************
    

import UIKit

/// 按钮点击间隔时间，防止重复点击
private var _interval: TimeInterval = 0.5

extension UIButton {
    
    convenience init(frame: CGRect, font: UIFont = .systemFont(ofSize: 17), text: String? = nil, textColor: UIColor? = nil) {
        self.init(frame: frame)
        titleLabel?.font = font
        setTitle(text, for: .normal)
        setTitleColor(textColor, for: .normal)
    }
    
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
    
    
    
    public class func startIntervalAction(interval: TimeInterval) {
        _interval = interval
        DispatchQueue.once(token: #function) {
            exchangeMethod(targetSel: #selector(sendAction), newSel: #selector(re_sendAction))
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
