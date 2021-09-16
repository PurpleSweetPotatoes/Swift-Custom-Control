// *******************************************
//  File Name:      UITabBarController+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/8/15 4:22 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

enum TabBarVcInfo: String {
    case name
    case title
    case selectImg
    case normalImg
}

public extension UITabBarController {
    /// 快捷创建tabbarVc方式
    ///
    /// - Parameter arr: 数组嵌套字典 vcName: selectImg: normalImg:
    /// - Returns: 返回tabbarVc
    class func createVc(arr: [[String: String]], needNav: Bool = true) -> UITabBarController {
        let tabbarVc = UITabBarController()

        tabbarVc.configVcs(arr: arr, needNav: needNav)

        return tabbarVc
    }

    func configVcs(arr: [[String: String]], needNav: Bool = true) {
        if arr.count == 0 {
            return
        }

        var vcArr: [UIViewController] = []
        for vcInfo in arr {
            guard let vcName = vcInfo[TabBarVcInfo.name.rawValue], let selectImg = vcInfo[TabBarVcInfo.selectImg.rawValue], let normalImg = vcInfo[TabBarVcInfo.normalImg.rawValue], let title = vcInfo[TabBarVcInfo.title.rawValue] else {
                continue
            }

            if let vc = BQTool.loadVc(vcName: vcName) {
                let tabbarItem = UITabBarItem(title: title, image: UIImage.orginImg(name: normalImg), selectedImage: UIImage.orginImg(name: selectImg))
                vc.tabBarItem = tabbarItem
                vc.title = title

                if needNav {
                    let navVc = BQNavgationController(rootViewController: vc)
                    vcArr.append(navVc)
                } else {
                    vcArr.append(vc)
                }
            }
        }

        viewControllers = vcArr
    }
}
