// *******************************************
//  File Name:      UnitConver.swift       
//  Author:         MrBai
//  Created Date:   2019/8/15 9:48 AM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************
    

import UIKit

protocol UnitConver  {
    func toDistance() -> String
    func toDiskSize() -> String
}

extension UnitConver {
    public func toDistance() -> String {
        if let value = self.converToNum(), value >= 0 {
            if value > 1000.0 {
                return String(format:"%.1fkm",value / 1000)
            } else {
                return String(format:"%.0fm",value)
            }
        } else {
            return ""
        }
    }
    
    public func toDiskSize() -> String {
        if let value = self.converToNum(), value >= 0 {
            let unit = 1024.0
            
            if value >= unit * unit {
                return String(format:"%.1f M",value / unit / unit)
            } else if value >= unit {
                return String(format:"%.1f KB",value / unit)
            } else {
                return String(format:"%.0f B",value)
            }
        } else {
            return ""
        }
    }
    
    private func converToNum() -> Double? {
        var num: Double? = nil
        switch self {
        case is String:
            num = Double(self as! String)
        case is Int:
            num = Double(self as! Int)
        case is UInt:
            num = Double(self as! UInt)
        case is Double:
            num = self as? Double
        case is Float:
            num = Double(self as! Float)
        default:
            num = nil
        }
        return num;
    }
    
    
}

extension String : UnitConver { }
extension Double : UnitConver { }
extension Float : UnitConver { }
extension Int : UnitConver {}
extension UInt : UnitConver {}
