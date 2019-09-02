// *******************************************
//  File Name:      AppDelegate+BQExtension.swift       
//  Author:         MrBai
//  Created Date:   2019/9/2 11:14 AM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

var crashHandler: ((NSException) -> Void?)?
var preCrashHandler: ((NSException) -> Void?)?

extension AppDelegate {
    /**
     if has other SDK CrashLog must set this function before
     
     let name = exception.name
     let reason = exception.reason
     let stackArr = exception.callStackSymbols
     print("\(name):\(reason ?? "no reason")\n\(stackArr)");
    **/
    func registerCrashHandler(handle:@escaping (NSException) -> Void?) {
        preCrashHandler = NSGetUncaughtExceptionHandler()
        crashHandler = handle
        NSSetUncaughtExceptionHandler { (exception) in
            if let preHand = preCrashHandler {
                preHand(exception)
            }
            
            if let hand = crashHandler {
                hand(exception)
            }
        }
    }
}
