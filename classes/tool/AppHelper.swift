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
        if let outStr = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return outStr
        } else if let outStr = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return outStr
        }
        return ""
    }

    static var identifier: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
    }

    static var version: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    static var statusHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }

    static var bottomSaveHeight: CGFloat {
        return statusHeight > 20 ? 34 : 0
    }

    static var languageCode: String {
        let languageCodeSpecifier = "-"
        if let language = Bundle.main.preferredLocalizations.first {
            // The first letter in script code should be a capital
            let parts = language.components(separatedBy: languageCodeSpecifier)
            if parts.count > 1 && parts[1].count > 1 {
                return "\(parts[0])\(languageCodeSpecifier)\(parts[1].prefix(1).uppercased())\(parts[1].dropFirst())"
            }
            return language
        } else {
            return "en"
        }
    }
}
