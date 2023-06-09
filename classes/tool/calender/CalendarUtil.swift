//
//  CalendarUtil.swift
//  Pods
//  
//  Created by Bai, Payne on 2023/6/2.
//  Copyright © 2023 Garmin All rights reserved
//  

import Foundation

public struct CalendarDate {
    // The yearMonthDay is like 20220101
    public let yearMonthDay: Int
    public let date: Date
    public let isToday: Bool
    // The secontion number like 202201
    public let sectionNumber: Int

    public var year: Int {
        yearMonthDay / 10000
    }
    public var month: Int {
        (yearMonthDay % 1000) / 100 + 1
    }

    public var day: Int {
        yearMonthDay % 100
    }

    public var isCurrentMonth: Bool {
        yearMonthDay / 100 == sectionNumber
    }


    public init(_ date: Date, sectionNumber: Int, isToday: Bool) {
        self.date = date
        self.yearMonthDay = Int(date.toString(format: "yyyyMMdd")) ?? 0
        self.sectionNumber = sectionNumber
        self.isToday = isToday
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
        let sectionNumber = Int(date.toString(format: "yyyyMM")) ?? 0
        let today = Date().startOfDay
        var outList: [CalendarDate] = [CalendarDate(fromDate, sectionNumber: sectionNumber, isToday: fromDate == today)]
        calendar.enumerateDates(startingAfter: fromDate, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) { nextDate, _, stop in
            if let nextDate = nextDate,
               nextDate <= endDate {
                outList.append(CalendarDate(nextDate, sectionNumber: sectionNumber, isToday: nextDate == today))
            } else {
                stop = true
            }
        }
        return outList
    }
}
