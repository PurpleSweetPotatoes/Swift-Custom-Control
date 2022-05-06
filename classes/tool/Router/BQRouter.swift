//
//  BQRouter.swift
//  Router-modular-demo
//
//  Created by baiqiang on 2017/6/10.
//  Copyright © 2017年 baiqiang. All rights reserved.
//

import UIKit

struct BQRouter {
    static func loadVc<T: BaseVc>(vcName: String, spaceName: String? = nil) -> T {
        return BQTool.loadVc(vcName: vcName, spaceName: spaceName) as! T
    }
}
