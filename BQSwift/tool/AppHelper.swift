// *******************************************
//  File Name:      AppHelper.swift       
//  Author:         MrBai
//  Created Date:   2021/9/18 2:36 PM
//    
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit

struct AppInfo {
    static var name: String {
        get {
            if let outStr = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
                return outStr
            } else if let outStr = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
                return outStr
            }
            return ""
        }
    }

    static var identifier: String {
        get {
            return Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
        }
    }
    
    static var version: String {
        get {
            return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        }
    }

    static var statusHeight: CGFloat  {
        get {
            return UIApplication.shared.statusBarFrame.height
        }
    }
     
    static var bottomSaveHeight: CGFloat {
        get {
            return statusHeight > 20 ? 34 : 0
        }
    }
}
