// *******************************************
//  File Name:      BQAlertViewManager.swift
//  Author:         MrBai
//  Created Date:   2022/2/23 5:55 PM
//
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    
import UIKit

// MARK: - BQAlertViewProtocol

/// 使用UIView继承
protocol BQAlertViewProtocol {
    /// 优先级， 数字越小优先级越高
    var priority: Int { get set }
    
    /// 展示视图
    var disV: UIView { get set }
    
    // MARK: - *** 可重写

    /// 展示动画
    func startAnimation()
    
    // MARK: - *** 默认实现

    /// 加入弹窗队列，自动展示
    func addAlertList(sup: UIView)
    
    /// 视图移除时调用
    func didRemoveSelf()

}

extension BQAlertViewProtocol where Self: UIView {
    
    func startAnimation() {
        disV.alpha = 0
        disV.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.disV.alpha = 1
            self?.disV.transform = CGAffineTransform.identity
        }
    }
    
    func addAlertList(sup: UIView) {
        BQAlertViewManager.addAlertInfo(v: self, supV: sup)
    }
    
    func didRemoveSelf() {
        BQAlertViewManager.showInfo = nil
        BQAlertViewManager.showNext()
    }
}

// MARK: - BQAlertInfo

struct BQAlertInfo {
    // MARK: Lifecycle

    init(view v: BQAlertViewProtocol, supV sv: UIView) {
        view = v
        supV = sv
    }

    // MARK: Internal

    let view: BQAlertViewProtocol
    let supV: UIView
}

// MARK: - BQAlertViewManager

enum BQAlertViewManager {
    static var showInfo: BQAlertInfo?
    
    static var alertList = [BQAlertInfo]()

    static func addAlertInfo(v: BQAlertViewProtocol, supV: UIView) {
        let info = BQAlertInfo(view: v, supV: supV)
        alertList.append(info)
        alertList.sort { $0.view.priority < $1.view.priority }
        BQAlertViewManager.showNext()
    }
    
    static func showNext() {
        if let _ = showInfo {
            return
        }
        
        if let info = alertList.first {
            showInfo = info
            info.supV.addSubview(info.view as! UIView)
            info.view.startAnimation()
            alertList.remove(at: 0)
        } else {
            BQLogger.log("队列资源展示完毕")
        }
    }
}
