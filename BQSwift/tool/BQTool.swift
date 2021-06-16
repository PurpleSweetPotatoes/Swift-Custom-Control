// *******************************************
//  File Name:      BQTool.swift
//  Author:         MrBai
//  Created Date:   2019/8/15 3:03 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************


import UIKit

struct BQTool {
    
    //MARK:- ***** 计算方法耗时 *****
    static func getFuntionUseTime(function:()->()) {
        let start = CACurrentMediaTime()
        function()
        let end = CACurrentMediaTime()
        print("耗时:\(end - start) s")
    }
    
    //MARK:- ***** 对象转json *****
    static func jsonFromObject(obj:Any) -> String {
        
        guard let data = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted) else {
            return String(describing: obj)
        }
        
        if let result = String(data: data, encoding: .utf8) {
            return result
        }
        
        return String(describing: obj)
    }
    
    static func currentSapceName() -> String {
        if sapceName == nil {
            var arrSapce = AppDelegate.classForCoder().description().split(separator: ".")
            arrSapce.removeLast()
            sapceName = arrSapce.joined()
        }
        return sapceName!
    }
    
    static func loadVc(vcName:String, spaceName: String? = nil) -> UIViewController? {
        
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
    static var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let identifier = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
            return String(cString: ptr)
        }
        switch identifier {
        case "iPhone6,1", "iPhone6,2":
            return "iPhone 5s"
        case "iPhone7,1":
            return "iPhone 6 Plus"
        case "iPhone7,2":
            return "iPhone 6"
        case "iPhone8,1":
            return "iPhone 6s"
        case "iPhone8,2":
            return "iPhone 6s Plus"
        case "iPhone8,4":
            return "iPhone SE"
        case "iPhone9,1":
            return "iPhone 7"
        case "iPhone9,2":
            return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":
            return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":
            return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":
            return "iPhone X"
        case "iPhone11,2":
            return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":
            return "iPhone XS Max (China)"
        case "iPhone11,8":
            return "iPhone XR"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
            return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":
            return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":
            return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":
            return "iPad Air"
        case "iPad5,3", "iPad5,4":
            return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":
            return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":
            return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":
            return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":
            return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":
            return "iPad Pro"
        case "AppleTV5,3":
            return "Apple TV"
        case "i386", "x86_64":
            return "Simulator"
        default:
            return identifier
        }
    }
    
    static var appName: String? {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
    }
    
    static var identifier: String? {
        return Bundle.main.bundleIdentifier
    }
    
    static var appVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    static var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    static var uuidIdentifier: String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    static func goPermissionSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }
    
    static func address(_ pt: UnsafeRawPointer) -> String {
        return String(format: "%p", Int(bitPattern: pt))
    }
    
    static func random(_ range: Range<Int>) -> Int {
        let count = UInt32(range.endIndex - range.startIndex)
        return Int(arc4random_uniform(count)) + range.startIndex
    }
    
    /// IP地址相关(第一个为外网ip)
    static func getIFAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            
            var ptr = ifaddr
            while ptr != nil {
                let flags = Int32((ptr?.pointee.ifa_flags)!)
                var addr = ptr?.pointee.ifa_addr.pointee
                
                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr?.sa_family == UInt8(AF_INET) || addr?.sa_family == UInt8(AF_INET6) {
                        
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr!, socklen_t((addr?.sa_len)!), &hostname, socklen_t(hostname.count),
                                        nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String(validatingUTF8: hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr?.pointee.ifa_next
            }
            
            freeifaddrs(ifaddr)
        }
        return addresses
    }
}
