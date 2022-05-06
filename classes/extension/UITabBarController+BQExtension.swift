// *******************************************
//  File Name:      UITabBarController+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/8/15 4:22 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

// MARK: - TabBarVcModel

public struct TabBarVcModel {
    var name: String = ""
    var title: String = ""
    var selectImg: String = ""
    var normalImg: String = ""

    public init(name: String, title: String, selectImg: String, normalImg: String) {
        self.name = name
        self.title = title
        self.selectImg = selectImg
        self.normalImg = normalImg
    }
}

public extension UITabBarController {
    /// 快捷创建tabbarVc方式
    ///
    /// - Parameter arr: 数组嵌套字典 vcName: selectImg: normalImg:
    /// - Returns: 返回tabbarVc
    static func createVc(arr: [TabBarVcModel], needNav: Bool = true) -> UITabBarController {
        let tabbarVc = UITabBarController()

        tabbarVc.configVcs(arr: arr, needNav: needNav)

        return tabbarVc
    }

    func configVcs(arr: [TabBarVcModel], needNav: Bool = true) {
        if arr.isEmpty {
            return
        }

        var vcArr: [UIViewController] = []
        for vcInfo in arr {
            if let vc = BQTool.loadVc(vcName: vcInfo.name) {
                let tabbarItem = UITabBarItem(title: title, image: UIImage.orginImg(name: vcInfo.normalImg), selectedImage: UIImage.orginImg(name: vcInfo.selectImg))
                vc.tabBarItem = tabbarItem
                vc.title = vcInfo.title

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
