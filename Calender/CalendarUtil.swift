//
//  CalendarUtil.swift
//  Pods
//  
//  Created by Bai, Payne on 2023/6/2.
//  Copyright © 2023 Garmin All rights reserved
//  

import Foundation

public struct CalendarDate: CustomDebugStringConvertible {
    // The value is like 202201
    let shortYearMonth: Int
    let date: Date
    let isCurrentMonth: Bool

    public var debugDescription: String {
        date.toString(format: "yyyy/MM/dd")
    }
}

public struct CalendarUtil {
    private let calendar = Calendar.current

    public init() {}

    public func currentYearDateList() -> [[CalendarDate]] {
        var outList: [[CalendarDate]] = []
        guard let startDate = Date().startDayOfYear else {
            return outList
        }

        for index in 0..<12 {
            if let nextDate = startDate.add(component: .month, value: index) {
                outList.append(monthList(from: nextDate))
            }
        }
        return outList
    }

    public func currentMonthList() -> [CalendarDate] {
        return monthList(from: Date())
    }

    public func monthList(from date: Date) -> [CalendarDate] {
        guard let fromDate = date.startDayOfMonth?.currentWeek(dayOfWeek: .sunday),
              let endDate = date.endDayOfMonth?.currentWeek(dayOfWeek: .saturday) else {
            return []
        }

        let components = date.components
        let shortYearMonth = (components.year ?? 0) * 100 + (components.month ?? 0)
        var outList: [CalendarDate] = [CalendarDate(shortYearMonth: shortYearMonth, date: fromDate, isCurrentMonth: fromDate.components.month == date.components.month)]
        calendar.enumerateDates(startingAfter: fromDate, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) { nextDate, _, stop in
            if let nextDate = nextDate,
               nextDate <= endDate {
                outList.append(CalendarDate(shortYearMonth: shortYearMonth, date: nextDate, isCurrentMonth: nextDate.components.month == date.components.month))
            } else {
                stop = true
            }
        }
        return outList
    }
}
