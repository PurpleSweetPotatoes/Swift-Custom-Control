//
//  UITabBarController+extension.swift
//  swift4.2Demo
//
//  Created by baiqiang on 2018/11/13.
//  Copyright © 2018年 baiqiang. All rights reserved.
//

import UIKit

public let kVcName: String = "kVcName"
public let kVcTitle: String = "kVcTitle"
public let kSelectImg: String = "kSelectImg"
public let kNormalImg: String = "kNormalImg"


extension UITabBarController {
    
    /// 快捷创建tabbarVc方式
    ///
    /// - Parameter arr: 数组嵌套字典 vcName: selectImg: normalImg:
    /// - Returns: 返回tabbarVc
    public class func createVc(arr: [[String: String]], needNav: Bool = true) -> UITabBarController {
        let tabbarVc = UITabBarController()
        
        if arr.count == 0 {
            return tabbarVc
        }
        
        var vcArr:[UIViewController] = []
        
        for vcInfo in arr {
            
            guard let vcName = vcInfo[kVcName], let selectImg = vcInfo[kSelectImg], let normalImg = vcInfo[kNormalImg], let title = vcInfo[kVcTitle] else {
                continue
            }
            
            if let vc = BQTool.loadVc(vcName: vcName) {
                
                let tabbarItem = UITabBarItem(title: title, image: UIImage.orginImg(name: normalImg), selectedImage: UIImage.orginImg(name: selectImg))
                vc.tabBarItem = tabbarItem
                vc.title = title
                
                if needNav {
                    let navVc = UINavigationController(rootViewController: vc)
                    vcArr.append(navVc)
                } else {
                    vcArr.append(vc)
                }
                
            }
        }
        
        tabbarVc.viewControllers = vcArr
        
        return tabbarVc
    }
}
