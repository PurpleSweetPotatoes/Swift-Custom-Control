// *******************************************
//  File Name:      BQWeakProxy.swift
//  Author:         MrBai
//  Created Date:   2019/8/15 3:07 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

class BQWeakProxy: NSObject {
    private weak var target: NSObject?
    init(target: NSObject) {
        self.target = target
        super.init()
    }

    override func forwardingTarget(for _: Selector!) -> Any? {
        return target
    }
}
