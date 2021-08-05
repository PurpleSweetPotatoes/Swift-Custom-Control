// *******************************************
//  File Name:      BQError.swift       
//  Author:         MrBai
//  Created Date:   2021/7/31 10:47 AM
//    
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import Foundation


struct BQError: Error {
    let desc: String
    let code: Int
    
    init(_ codeNum: Int, _ reason: String) {
        code = codeNum
        desc = reason
    }
    
    var errorDescription: String? {
        return desc
    }
}
