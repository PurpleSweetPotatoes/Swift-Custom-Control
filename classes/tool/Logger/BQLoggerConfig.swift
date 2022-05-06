// *******************************************
//  File Name:      BQLoggerConfig.swift       
//  Author:         MrBai
//  Created Date:   2022/4/30 13:19
//    
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import Foundation
import UIKit


public enum BQLogType: Int {
    
    case all = 0
    case debug
    case info
    case defualt
    case error
    case fault
    
    var colorStr: String {
        switch self {
        case .debug:
            return "📓"
        case .info:
            return "📘"
        case .defualt:
            return "📗"
        case .error:
            return "📕"
        default:
            return ""
        }
    }
}

public struct BQLoggerConfig {
    
    /// 输出队列
    var loggerQueue = DispatchQueue(label: "com.mrbai.logger.queue")
    @discardableResult
    mutating public func queue(_ queue: DispatchQueue) -> Self {
        self.loggerQueue = queue
        return self;
    }
    
    /// 输出日志
    var logType: BQLogType = .all
    @discardableResult
    mutating public func logType(_ logType: BQLogType) -> Self {
        self.logType = logType
        return self;
    }
    
    /// 日志保存等级 .defualt以上保存
    var saveType: BQLogType = .defualt
    @discardableResult
    mutating public func saveType(_ saveType: BQLogType) -> Self {
        self.saveType = saveType
        return self;
    }
    
    /// 日志最大(单位b) 默认6M
    var maxSize: Double = 1024 * 1024 * 6
    @discardableResult
    mutating public func maxSize(_ maxSize: Double) -> Self {
        self.maxSize = maxSize
        return self;
    }
    
    /// 日志保留时长(单位s) 默认7天
    var saveTime: Double = 60 * 60 * 24 * 7
    @discardableResult
    mutating public func saveTime(_ saveTime: Double) -> Self {
        self.saveTime = saveTime
        return self;
    }
    
    @discardableResult
    public func systemVcLog() -> Self {
        DispatchQueue.once(token: #function) {
            UIViewController.exchangeMethod(targetSel: #selector(UIViewController.viewDidLoad), newSel: #selector(UIViewController.bqLoggerViewDidLoad))
            UIViewController.exchangeMethod(targetSel: #selector(UIViewController.viewWillAppear(_:)), newSel: #selector(UIViewController.bqLoggerViewWillAppear(_:)))
//            UIViewController.exchangeMethod(targetSel: #selector(UIViewController.viewDidAppear(_:)), newSel: #selector(UIViewController.bqLoggerViewDidAppear(_:)))
            UIViewController.exchangeMethod(targetSel: #selector(UIViewController.viewWillDisappear(_:)), newSel: #selector(UIViewController.bqLoggerViewWillDisappear(_:)))
//            UIViewController.exchangeMethod(targetSel: #selector(UIViewController.viewDidDisappear(_:)), newSel: #selector(UIViewController.bqLoggerViewDidDisappear(_:)))
            UIViewController.exchangeMethod(targetSel: #selector(UIViewController.present(_:animated:completion:)), newSel: #selector(UIViewController.bqLoggerPresent(_:animated:completion:)))
            UINavigationController.exchangeMethod(targetSel: #selector(UINavigationController.pushViewController(_:animated:)), newSel: #selector(UINavigationController.bqLoggerPushViewController(_:animated:)))
        }
        return self
    }
    
    func canLog(type: BQLogType) -> Bool {
        type.rawValue > logType.rawValue
    }
    
    func canSave(type: BQLogType) -> Bool {
        type.rawValue >= saveType.rawValue
    }
}
