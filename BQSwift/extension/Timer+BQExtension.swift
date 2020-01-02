// *******************************************
//  File Name:      Timer+BQExtension.swift       
//  Author:         MrBai
//  Created Date:   2019/9/17 2:53 PM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************
    

import UIKit

extension Timer {
    class public func configTimer(timeInterval ti: TimeInterval, target aTarget: Any, selector aSelector: Selector, userInfo: Any?, repeats yesOrNo: Bool) -> Timer {
        let proxy = BQWeakProxy(target: aTarget as! NSObject)
        let timer = scheduledTimer(timeInterval: ti, target: proxy, selector: aSelector, userInfo: userInfo, repeats: yesOrNo)
        RunLoop.current.add(timer, forMode: .common)
        return timer
    }
}
