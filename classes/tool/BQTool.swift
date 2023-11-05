// *******************************************
//  File Name:      BQTool.swift
//  Author:         MrBai
//  Created Date:   2019/8/15 3:03 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit
 
public struct BQTool {

    // MARK: - ***** 计算方法耗时 *****

    static public func getFuntionUseTime(function: () -> Void) {
        let start = CACurrentMediaTime()
        function()
        let end = CACurrentMediaTime()
        BQLogger.log("耗时:\(end - start) s")
    }

    // MARK: - ***** 对象转json *****

    static public func jsonFromObject(obj: Any) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted) else {
            return String(describing: obj)
        }
        
        if let result = String(data: data, encoding: .utf8) {
            return result
        }

        return String(describing: obj)
    }

    static public func loadVc(vcName: String, spaceName: String? = nil) -> UIViewController? {
        var clsName = ""

        if let space = spaceName {
            clsName = space + "." + vcName
        } else {
            clsName = (currentSapceName ?? "") + "." + vcName
        }

        let cls = NSClassFromString(clsName) as? UIViewController.Type
        let vc = cls?.init()

        if let valueVc = vc {
            return valueVc
        } else {
            return nil
        }
    }

    static public var currentSapceName: String? {
        return Bundle.main.infoDictionary?["CFBundleExecutable"] as? String
    }
}
