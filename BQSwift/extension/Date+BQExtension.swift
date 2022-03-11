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
}
