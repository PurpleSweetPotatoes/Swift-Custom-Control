// *******************************************
//  File Name:      Device+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/11/12 10:31 AM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

public enum DeviceType: String {
    #if os(iOS)
        case iPhone
        case iPad
        case iPod
        case simulator
    #elseif os(OSX)
        case iMac
        case macMini
        case macPro
        case macBook
        case macBookAir
        case macBookPro
        case xserve
    #endif
    case unknown
}

public enum DeviceName: String {
    /*** iPhone ***/
    case iPhone4
    case iPhone4S
    case iPhone5
    case iPhone5C
    case iPhone5S
    case iPhone6
    case iPhone6Plus
    case iPhone6S
    case iPhone6SPlus
    case iPhoneSE
    case iPhone7
    case iPhone7Plus
    case iPhone8
    case iPhone8Plus
    case iPhoneX
    case iPhoneXS
    case iPhoneXS_Max
    case iPhoneXR
    case iPhone11
    case iPhone11Pro
    case iPhone11Pro_Max

    /*** iPad ***/
    case iPad1
    case iPad2
    case iPad3
    case iPad4
    case iPad5
    case iPad6
    case iPad7
    case iPadAir
    case iPadAir2
    case iPadAir3
    case iPadMini
    case iPadMini2
    case iPadMini3
    case iPadMini4

    /*** iPadPro ***/
    case iPadPro9_7Inch
    case iPadPro12_9Inch
    case iPadPro10_5Inch
    case iPadPro12_9Inch2
    case iPadPro11_0Inch
    case iPadPro12_9Inch3

    /*** iPod ***/
    case iPodTouch1Gen
    case iPodTouch2Gen
    case iPodTouch3Gen
    case iPodTouch4Gen
    case iPodTouch5Gen
    case iPodTouch6Gen

    /*** simulator ***/
    case simulator

    /*** unknown ***/
    case unknown
}

extension UIDevice {
    fileprivate static func getVersionCode() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)

        let versionCode = String(validatingUTF8: NSString(bytes: &systemInfo.machine, length: Int(_SYS_NAMELEN), encoding: String.Encoding.ascii.rawValue)!.utf8String!)!

        return versionCode
    }

    fileprivate static func getVersion(code: String) -> DeviceName {
        switch code {
        /*** iPhone ***/
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return .iPhone4
        case "iPhone4,1", "iPhone4,2", "iPhone4,3": return .iPhone4S
        case "iPhone5,1", "iPhone5,2": return .iPhone5
        case "iPhone5,3", "iPhone5,4": return .iPhone5C
        case "iPhone6,1", "iPhone6,2": return .iPhone5S
        case "iPhone7,2": return .iPhone6
        case "iPhone7,1": return .iPhone6Plus
        case "iPhone8,1": return .iPhone6S
        case "iPhone8,2": return .iPhone6SPlus
        case "iPhone8,3", "iPhone8,4": return .iPhoneSE
        case "iPhone9,1", "iPhone9,3": return .iPhone7
        case "iPhone9,2", "iPhone9,4": return .iPhone7Plus
        case "iPhone10,1", "iPhone10,4": return .iPhone8
        case "iPhone10,2", "iPhone10,5": return .iPhone8Plus
        case "iPhone10,3", "iPhone10,6": return .iPhoneX
        case "iPhone11,2": return .iPhoneXS
        case "iPhone11,4", "iPhone11,6": return .iPhoneXS_Max
        case "iPhone11,8": return .iPhoneXR
        case "iPhone12,1": return .iPhone11
        case "iPhone12,3": return .iPhone11Pro
        case "iPhone12,5": return .iPhone11Pro_Max

        /*** iPad ***/
        case "iPad1,1", "iPad1,2": return .iPad1
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return .iPad2
        case "iPad3,1", "iPad3,2", "iPad3,3": return .iPad3
        case "iPad3,4", "iPad3,5", "iPad3,6": return .iPad4
        case "iPad6,11", "iPad6,12": return .iPad5
        case "iPad7,5", "iPad7,6": return .iPad6
        case "iPad4,1", "iPad4,2", "iPad4,3": return .iPadAir
        case "iPad5,3", "iPad5,4": return .iPadAir2
        case "iPad11,3", "iPad11,4": return .iPadAir3
        case "iPad2,5", "iPad2,6", "iPad2,7": return .iPadMini
        case "iPad4,4", "iPad4,5", "iPad4,6": return .iPadMini2
        case "iPad4,7", "iPad4,8", "iPad4,9": return .iPadMini3
        case "iPad5,1", "iPad5,2": return .iPadMini4

        /*** iPadPro ***/
        case "iPad6,3", "iPad6,4": return .iPadPro9_7Inch
        case "iPad6,7", "iPad6,8": return .iPadPro12_9Inch
        case "iPad7,1", "iPad7,2": return .iPadPro12_9Inch2
        case "iPad7,3", "iPad7,4": return .iPadPro10_5Inch
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return .iPadPro11_0Inch
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return .iPadPro12_9Inch3

        /*** iPod ***/
        case "iPod1,1": return .iPodTouch1Gen
        case "iPod2,1": return .iPodTouch2Gen
        case "iPod3,1": return .iPodTouch3Gen
        case "iPod4,1": return .iPodTouch4Gen
        case "iPod5,1": return .iPodTouch5Gen
        case "iPod7,1": return .iPodTouch6Gen

        /*** Simulator ***/
        case "i386", "x86_64": return .simulator

        default: return .unknown
        }
    }

    public static func type() -> DeviceType {
        let versionCode = getVersionCode()

        if versionCode.contains("iPhone") {
            return .iPhone
        } else if versionCode.contains("iPad") {
            return .iPad
        } else if versionCode.contains("iPod") {
            return .iPod
        } else if versionCode == "i386" || versionCode == "x86_64" {
            return .simulator
        } else {
            return .unknown
        }
    }

    public static func name() -> DeviceName {
        return getVersion(code: getVersionCode())
    }
}
