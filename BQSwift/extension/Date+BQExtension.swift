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
        get {
            return String(format: "%.lf", self.timeIntervalSince1970)
        }
    }
    
    /// 格式化日期
    ///
    /// - Parameters:
    ///   - format: y、M、d、H、m、s
    ///   - localId: 地域标示符
    func timeStringFormat(format: String = "yyyy/MM/dd", localId: String = "zh_CN") -> String {
        _dateFormatter.dateFormat = format
        if _dateFormatter.locale.identifier != localId {
            let local = Locale(identifier: localId)
            _dateFormatter.locale = local
        }
        return _dateFormatter.string(from: self)
    }
    
    /// 时间组件
    func components() -> DateComponents {
        return Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,.weekday], from: self)
    }
    
}
