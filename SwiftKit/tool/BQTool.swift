//
//  BQTool.swift
//  swift4.2Demo
//
//  Created by baiqiang on 2018/10/8.
//  Copyright © 2018年 baiqiang. All rights reserved.
//

import UIKit

class BQTool: NSObject {
    
    static private var sapceName: String?
    
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
    
    class func currentSapceName() -> String {
        if sapceName == nil {
            var arrSapce = self.classForCoder().description().split(separator: ".")
            arrSapce.removeLast()
            sapceName = arrSapce.joined()
        }
        return sapceName!
    }
    
    class func loadVc(vcName:String, spaceName: String? = nil) -> UIViewController? {
        
        var clsName = ""
        
        if let space = spaceName{
            
            clsName = space + "." + vcName
            
        } else {

            clsName = self.currentSapceName() + "." + vcName
        }
        
        let cls = NSClassFromString(clsName) as? UIViewController.Type
        let vc = cls?.init()
        
        if let valueVc = vc {
            return valueVc
        } else {
            return nil
        }
    }
    
    ///获取设备型号
    class var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone9,1":                               return "iPhone 7"
        case "iPhone9,2":                               return "iPhone 7 Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
    class func currentBundleIdentifier() -> String {
        return Bundle.main.bundleIdentifier!
    }
    
    class func currentVersion() -> String {
        return UIDevice.current.systemVersion
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
