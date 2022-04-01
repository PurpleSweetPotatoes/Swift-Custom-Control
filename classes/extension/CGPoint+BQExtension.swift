// *******************************************
//  File Name:      CGPoint+BQExtension.swift       
//  Author:         MrBai
//  Created Date:   2022/4/1 16:59
//    
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit

extension CGPoint {
    
    static func distance(_ from: CGPoint, to: CGPoint) -> CGFloat {
        let xd = from.x - to.x
        let yd = from.y - to.y
        return sqrt(xd*xd + yd*yd)
    }
    
    static func agnle(_ pt: CGPoint, centerPt cPt: CGPoint) -> CGFloat {
        
        let y = abs(pt.y - cPt.y)
        let x = abs(pt.x - cPt.x)
        var agnle = atan(y / x)
        
        // 四象限处理,注意iOS，y坐标系是反的
        if pt.x >= cPt.x { // 右侧
            if pt.y <= cPt.y { // 右上
                agnle = 2 * CGFloat.pi - agnle
            } else { //右上 正常角度
                
            }
        } else { //左侧
            if pt.y <= cPt.y { // 左上
                agnle = CGFloat.pi + agnle
            } else { //左下
                agnle = CGFloat.pi - agnle
            }
        }
        
        return agnle
    }
}
