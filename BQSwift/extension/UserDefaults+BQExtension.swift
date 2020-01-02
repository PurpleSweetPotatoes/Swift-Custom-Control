// *******************************************
//  File Name:      UserDefaults+BQExtension.swift       
//  Author:         MrBai
//  Created Date:   2019/11/13 11:54 AM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************
    

import Foundation


public extension UserDefaults {
    
    /// 建议值用String保存
    class subscript(key: String) -> Any? {
        get {
            return UserDefaults.standard.object(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
    
}
