// *******************************************
//  File Name:      Date+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/8/19 11:40 AM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

private let _dateFormatter = DateFormatter()

extension Date {
    /// 时间戳
    var timeStamp: String {
        return String(format: "%.lf", timeIntervalSince1970)
    }

    /// 格式化日期
    /// - Parameters:
    ///   - format: y、M、d、H、m、s
    func toString(format: String = "yyyy/MM/dd HH:mm:ss", localId: String = "zh_CN") -> String {
        _dateFormatter.dateFormat = format
        return _dateFormatter.string(from: self)
    }
    
    /// 加载Date
    /// - Parameters:
    ///   - timeStr: 时间字符串
    ///   - format: 格式化方式
    /// - Returns: Date?
    static func load(_ timeStr: String, format: String = "yyyy/MM/dd") -> Date? {
        _dateFormatter.dateFormat = format
        return _dateFormatter.date(from: timeStr)
    }

    /// 时间组件
    func components() -> DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: self)
    }
    
    /// 获取当日初和明日初
    /// - Returns: (当日初，明日初)
    func dayStartAndEnd() -> (Date,Date)? {
        return dateStartAndEnd([.year, .month, .day]) { compon in
            var com = compon
            com.day = (com.day ?? 0) + 1
            return com
        }
    }
    
    /// 获取当月初和下个月初
    /// - Returns: (当月初，下个月初)
    func monthStartAndEnd() -> (Date,Date)? {
        return dateStartAndEnd([.year, .month]) { compon in
            var com = compon
            com.month = (com.month ?? 0) + 1
            return com
        }
    }
    
    /// 获取当年初和下年初
    /// - Returns: (当年初，下年初)
    func yearStartAndEnd() -> (Date,Date)? {
        return dateStartAndEnd([.year]) { compon in
            var com = compon
            com.year = (com.year ?? 0) + 1
            return com
        }
    }
    
    func dateStartAndEnd(_ components: Set<Calendar.Component>, handle: (DateComponents) -> DateComponents) -> (Date,Date)? {
        let calend = Calendar.current
        let components = calend.dateComponents(components, from: self)
        let startDate = calend.date(from: components)
        let endDate = calend.date(from: handle(components))
        if let start = startDate, let end = endDate {
            return (start, end)
        }
        return nil
    }
}


extension DateComponents {
    public func dateNum() -> Int {
        return (year ?? 0) * 10000 + (month ?? 0) * 100 + (day ?? 0)
    }
    
    public var chainWeekStr: String {
        if let wday = weekday {
            switch wday {
            case 1: return "星期天"
            case 2: return "星期一"
            case 3: return "星期二"
            case 4: return "星期三"
            case 5: return "星期四"
            case 6: return "星期五"
            case 7: return "星期六"
            default: return ""
            }
        }
        return ""
    }
}
