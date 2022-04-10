// *******************************************
//  File Name:      Dictionary+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2021/9/18 11:31 AM
//
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import Foundation

extension Dictionary where Key == String {
    func toString(boundary: Bool = false) -> String {
        var outStr = ""
        let keys = self.keys.sorted()
        if !keys.isEmpty {
            if boundary { outStr.append("[") }

            for key in keys {
                if let value = self[key] {
                    if outStr.count > 1 { outStr.append("&") }

                    if let va = value as? [String: AnyObject] {
                        outStr.append("\(key)=\(va.toString(boundary: true))")
                    } else if let va = value as? [String] {
                        outStr.append("\(key)=\(va.toString())")
                    } else {
                        outStr.append("\(key)=\(value)")
                    }
                }
            }
            if boundary { outStr.append("]") }
        }
        return outStr
    }
    func hasKey(_ key: String) -> Bool {
        return self[key] != nil
    }
}
