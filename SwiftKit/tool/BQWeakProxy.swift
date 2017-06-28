//
//  BQWeakProxy.swift
//  swift-test
//
//  Created by baiqiang on 2017/6/28.
//  Copyright © 2017年 baiqiang. All rights reserved.
//

import UIKit

class BQWeakProxy: NSObject {
    private weak var target: NSObject?
    init(target: NSObject) {
        self.target = target
        super.init()
    }
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }
}
