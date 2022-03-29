// *******************************************
//  File Name:      DispatchQueue+BQextension.swift
//  Author:         MrBai
//  Created Date:   2019/8/15 9:26 AM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import Foundation

typealias TaskBlock = (_ cancel: Bool) -> Void

extension DispatchQueue {
    private static var _onceTracker = [String]()

    public static func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        if !_onceTracker.contains(token) {
            _onceTracker.append(token)
            block()
        }
        objc_sync_exit(self)
    }

    @discardableResult
    static func after(_ time: TimeInterval, task: @escaping () -> Void) -> TaskBlock? {
        func dispatch_later(block: @escaping () -> Void) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time, execute: block)
        }
        var result: TaskBlock?
        let delayedClosure: TaskBlock = {
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

    static func cancel(task: TaskBlock?) {
        task?(true)
    }
}
