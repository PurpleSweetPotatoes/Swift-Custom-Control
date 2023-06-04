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

public enum BQWeekDay: Int, CaseIterable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

public extension Date {
    /// 时间戳
    var timeStamp: String {
        String(format: "%.lf", timeIntervalSince1970)
    }

    /// 时间组件
    var components: DateComponents {
        Calendar.current.dateComponents([.era, .year, .month, .day, .hour, .minute, .second, .weekday], from: self)
    }

    /// 格式化日期
    /// - Parameters:
    ///   - format: y、M、d、H、m、s
    func toString(format: String = "yyyy/MM/dd HH:mm:ss", localId: String? = nil) -> String {
        _dateFormatter.dateFormat = format
        if let localId = localId {
            _dateFormatter.timeZone = TimeZone(identifier: localId)
        } else {
            _dateFormatter.timeZone = TimeZone.current
        }
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

    func add(component: Calendar.Component, value: Int) -> Date? {
        Calendar.current.date(byAdding: component, value: value, to: self)
    }

    func calendarDistanceDay(_ toDate: Date) -> Int {
        let fromDate = self.startOfDay
        let toDate = toDate.startOfDay
        guard let day = Calendar.current.dateComponents([.day,], from: fromDate, to: toDate).day else {
            return Int(distance(to: toDate) / 60 * 60 * 24)
        }
        return day
    }

    func isSameYear(_ targetDate: Date) -> Bool {
        components.year == targetDate.components.year
    }
}

// MARK: calendar date
public extension Date {
    var startDayOfMonth: Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)
    }

    var endDayOfMonth: Date? {
        guard let startDayOfMonth = startDayOfMonth else { return nil }
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.day = -1
        return calendar.date(byAdding: components, to: startDayOfMonth)
    }

    var startDayOfWeek: Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)
    }


    /// Week start from Sunday to Saturday
    func currentWeek(dayOfWeek: BQWeekDay) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear, .weekday], from: self)
        components.weekday = dayOfWeek.rawValue
        return calendar.date(from: components)
    }

    var endDayOfWeek: Date? {
        guard let startDayOfWeek = startDayOfWeek else { return nil }
        return Calendar.current.date(byAdding: .day, value: 6, to: startDayOfWeek)
    }

    var startDayOfYear: Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return calendar.date(from: components)
    }

    var endDayOfYear: Date? {
        guard let startDayOfYear = startDayOfYear else { return nil }
        return Calendar.current.date(byAdding: .day, value: 364, to: startDayOfYear)
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        startOfDay.addingTimeInterval(60 * 60 * 24 - 1)
    }

    var weekList: [Date] {
        guard let startDayOfWeek = startDayOfWeek else { return [] }
        var weekList: [Date] = []
        let calendar = Calendar.current
        var components = DateComponents()
        for index in 0..<7 {
            components.day = Int(index)
            if let date = calendar.date(byAdding: components, to: startDayOfWeek) {
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
