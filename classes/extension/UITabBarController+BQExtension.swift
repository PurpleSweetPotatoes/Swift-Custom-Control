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
    var selectImage: String = ""
    var normalImage: String = ""

    public init(name: String, title: String, selectImage: String, normalImage: String) {
        self.name = name
        self.title = title
        self.selectImage = selectImage
        self.normalImage = normalImage
    }
}

public extension UITabBarController {
    /// 快捷创建tabbarVc方式
    ///
    /// - Parameter arr: 数组嵌套字典 vcName: selectImage: normalImage:
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
                let tabbarItem = UITabBarItem(title: title, image: UIImage.originalImage(name: vcInfo.normalImage), selectedImage: UIImage.originalImage(name: vcInfo.selectImage))
                vc.tabBarItem = tabbarItem
                vc.title = vcInfo.title

                if needNav {
                    let navVc = BQNavigationController(rootViewController: vc)
                    vcArr.append(navVc)
                } else {
                    vcArr.append(vc)
                }
            }
        }

        viewControllers = vcArr
    }
}
