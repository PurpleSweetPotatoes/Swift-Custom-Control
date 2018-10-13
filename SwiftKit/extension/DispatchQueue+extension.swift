//
//  DispatchQueue+extension.swift
//  swift4.2Demo
//
//  Created by baiqiang on 2018/10/6.
//  Copyright © 2018年 baiqiang. All rights reserved.
//


import Foundation

typealias Task = (_ cancel: Bool) -> Void

extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    public class func once(_ token: String, _ block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
    
    @discardableResult
    class func delay(_ time:TimeInterval, task:@escaping ()->()) -> Task? {
        func dispatch_later(block:@escaping ()->()) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time, execute: block)
        }
        var result: Task?
        let delayedClosure: Task = {
            cancel in
            if !cancel {
                DispatchQueue.main.async(execute: task)
            }
            result = nil
        }
        result = delayedClosure
        dispatch_later {
            if let closure = result {
                closure(false)
            }
        }
        return result
    }
    
    class func cancel(task:Task?) {
        task?(true)
    }
}
