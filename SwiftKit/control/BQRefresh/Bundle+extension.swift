//
//  Bundle+extension.swift
//  BQRefresh
//
//  Created by baiqiang on 2017/7/4.
//  Copyright © 2017年 baiqiang. All rights reserved.
//

import UIKit

enum RefreshText: String {
    case headerIdle = "BQRefreshHeaderIdleText"
    case headerPull = "BQRefreshHeaderPullingText"
    case headerRefresh = "BQRefreshHeaderRefreshingText"
    case footIdle = "BQRefreshAutoFooterIdleText"
    case footRefresh = "BQRefreshAutoFooterRefreshingText"
    case footNoMore = "BQRefreshAutoFooterNoMoreDataText"
}

private var img: UIImage?
private var refresh: Bundle?
private var localBundle: Bundle?
extension Bundle {
    public class func refreshBunle() -> Bundle? {
        if refresh == nil {
            refresh = Bundle(path: Bundle.main.path(forResource: "BQRefresh", ofType: "bundle") ?? "")
        }
        return refresh
    }
    public class func arrowImage() -> UIImage? {
        if img == nil {
            let arrImg = UIImage(contentsOfFile: Bundle.refreshBunle()?.path(forResource: "arrow@2x", ofType: "png") ?? "")
            img = arrImg
        }
        return img
    }
    class func refreshString(key: RefreshText, value:String? = "") -> String{
        if localBundle == nil {
            var language = Locale.preferredLanguages.first ?? "en" //默认英文
            if language.hasPrefix("en") {
                language = "en"
            }else if language.hasPrefix("zh") {
                if language.range(of: "Hans") != nil {
                    language = "zh-Hans" // 简体中文
                }else {
                    language = "zh-Hant" // 繁体中文
                }
            }
            localBundle = Bundle(path: Bundle.refreshBunle()?.path(forResource: language, ofType: "lproj") ?? "")
        }
        let backStr = localBundle?.localizedString(forKey: key.rawValue, value: value, table: nil)
        return Bundle.main.localizedString(forKey: key.rawValue, value: backStr, table: nil)
    }
}














