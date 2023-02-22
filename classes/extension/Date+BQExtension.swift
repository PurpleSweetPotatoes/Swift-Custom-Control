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

public extension Date {
    /// 时间戳
    var timeStamp: String {
        String(format: "%.lf", timeIntervalSince1970)
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
        Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: self)
    }

    func addDay(_ day: Int) -> Date? {
        Calendar.current.date(byAdding: .day, value: day, to: self)
    }
}

// MARK: calendar date
public extension Date {
    var startDayOfMonth: Date? {
        let calender = Calendar.current
        let componets = calender.dateComponents([.year, .month], from: self)
        return calender.date(from: componets)
    }

    var endDayOfMonth: Date? {
        guard let startDayOfMonth = startDayOfMonth else { return nil }
        let calendar = Calendar.current
        var componets = DateComponents()
        componets.month = 1
        componets.day = -1
        return calendar.date(byAdding: componets, to: startDayOfMonth)
    }

    var startDayOfWeek: Date? {
        let calender = Calendar.current
        let componets = calender.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calender.date(from: componets)
    }

    var endDayOfWeek: Date? {
        guard let startDayOfWeek = startDayOfWeek else { return nil }
        return Calendar.current.date(byAdding: .day, value: 6, to: startDayOfWeek)
    }

    var startDayOfYear: Date? {
        let calender = Calendar.current
        let componets = calender.dateComponents([.year], from: self)
        return calender.date(from: componets)
    }

    var endDayOfYear: Date? {
        guard let startDayOfYear = startDayOfYear else { return nil }
        return Calendar.current.date(byAdding: .day, value: 364, to: startDayOfYear)
    }

    var startTime: Date? {
        let calender = Calendar.current
        let componets = calender.dateComponents([.year, .month, .day], from: self)
        return calender.date(from: componets)
    }

    var endTime: Date? {
        let calender = Calendar.current
        var componets = calender.dateComponents([.year, .month, .day], from: self)
        componets.hour = 23
        componets.minute = 59
        componets.second = 59
        return calender.date(from: componets)
    }

    var weekList: [Date] {
        guard let startDayOfWeek = startDayOfWeek else { return [] }
        var weekList: [Date] = []
        let calendar = Calendar.current
        var componets = DateComponents()
        for index in 0..<7 {
            componets.day = Int(index)
            if let date = calendar.date(byAdding: componets, to: startDayOfWeek) {
                weekList.append(date)
            }
        }
        return weekList
    }
}

public extension DateComponents {
    func dateNum() -> Int {
        (year ?? 0) * 10000 + (month ?? 0) * 100 + (day ?? 0)
    }

    var chainWeekStr: String {
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
