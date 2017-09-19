//
//  Int+extension.swift
//  swift-Test
//
//  Created by MrBai on 2017/6/14.
//  Copyright © 2017年 MrBai. All rights reserved.
//

import UIKit

extension Int {
    
    /// 转化为距离字符串
    public var distance : String {
        
        guard self > 0 else {
            return ""
        }
        
        let unit = 1000.0
        guard Double(self) < unit else {
            return String(format:"%.1fkm",Double(self) / unit)
        }

        return "\(self)m"
    }
    
    /// 转化为文件大小字符串
    public var diskSize : String {
        
        guard self > 0 else {
            return ""
        }
        
        let unit = 1024.0
        guard Double(self) < unit * unit else {
            return String(format:"%.1fM",Double(self) / unit / unit)
        }
        
        guard Double(self) < unit else {
            return String(format:"%.0fKB",Double(self) / unit)
        }
        
        return "\(self)B"
    }
    
    // year day hour minute second to TimeInterval
    var year: TimeInterval {
        return 365 * self.day
    }
    
    var day: TimeInterval {
        return 24 * self.hour
    }
    
    var hour: TimeInterval {
        return 60 * self.minute
    }

    var minute: TimeInterval {
        return 60 * self.second
    }
    
    var second: TimeInterval {
        return TimeInterval(self)
    }
}
