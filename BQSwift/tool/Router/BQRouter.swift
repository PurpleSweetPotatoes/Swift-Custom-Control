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
        var clsName = ""

        if let space = spaceName {
            clsName = space + "." + vcName
        } else {
            clsName = BQTool.currentSapceName() + "." + vcName
        }

        let cls = NSClassFromString(clsName) as? BaseVc.Type
        let vc = cls?.init()

        if let valueVc = vc {
            return valueVc as! T
        } else {
            return ErrorVc() as! T
        }
    }
}
