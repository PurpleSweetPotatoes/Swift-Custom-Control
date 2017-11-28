//
//  BQTool.swift
//  HaoJiLai
//
//  Created by baiqiang on 16/11/1.
//  Copyright © 2016年 baiqiang. All rights reserved.
//

import UIKit


class BQTool: NSObject {

    //MARK:- ***** 弹出框 *****
    class func showAlert(content:String, title:String? = nil, handle:(() -> ())? = nil) {
        self.showAlert(content: content, title: title, btnTitleArr: ["确定"]) { (index) in
            if let block = handle {
                block()
            }
        }
    }
    
    class func showAlert(content:String, title:String? = nil, btnTitleArr:Array<String>,handle:@escaping ((_ index:Int) -> Void)) {
        let alertVc:UIAlertController = UIAlertController(title: title, message: content, preferredStyle: UIAlertControllerStyle.alert);
        for title in btnTitleArr {
            let action:UIAlertAction = UIAlertAction(title: title, style: UIAlertActionStyle.default, handler: { (action) in
                let index = btnTitleArr.index(of: action.title!)
                handle(index!)
            })
            alertVc.addAction(action)
        }
        self.currentVc()?.present(alertVc, animated: true, completion: nil)
    }
    
    class func currentVc() -> UIViewController? {
        var vc = UIApplication.shared.keyWindow?.rootViewController
        while let presentVc = vc?.presentedViewController {
            vc = presentVc
        }
        return vc
    }
    
    //MARK:- ***** 计算方法耗时 *****
    class func getFuntionUseTime(function:()->()) {
        let start = CACurrentMediaTime()
        function()
        let end = CACurrentMediaTime()
        Log("方法耗时为：\(end-start)")
    }
    
    //MARK:- ***** 对象转json *****
    class func jsonFromObject(obj:Any) -> String {
        let data:Data = try! JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
        let json:String = String(data: data, encoding: .utf8)!
        return json
    }
    class func currentBundleIdentifier() -> String {
        return Bundle.main.bundleIdentifier!
    }
    class func uuidIdentifier() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
}

/// 需要在build setting -> other swift flags -> Debug 中设置 -D DEBUG
func Log<T>(_ messsage : T, file : String = #file, funcName : String = #function, lineNum : Int = #line) {
    #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("\(fileName)-line:\(lineNum) ==> \(messsage)")
    #endif
}
