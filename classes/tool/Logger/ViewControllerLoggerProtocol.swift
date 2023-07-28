// *******************************************
//  File Name:      ViewControllerLoggerProtocol.swift       
//  Author:         MrBai
//  Created Date:   2022/4/30 13:09
//    
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit

protocol ViewControllerLoggerProtocol {
    func bqLoggerViewDidLoad()
    func bqLoggerViewWillAppear(_ animated: Bool)
    func bqLoggerViewWillDisappear(_ animated: Bool)
    func bqLoggerPresent(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

extension UIViewController {
    @objc func bqLoggerViewDidLoad() {
        BQLogger.log("\(self) viewDidLoad")
        bqLoggerViewDidLoad()
    }
    
    @objc func bqLoggerViewWillAppear(_ animated: Bool) {
        BQLogger.log("\(self) ViewWillAppear")
        bqLoggerViewWillAppear(animated)
    }
    
    @objc func bqLoggerViewWillDisappear(_ animated: Bool) {
        BQLogger.log("\(self) viewWillDisappear")
        bqLoggerViewWillDisappear(animated)
    }
    
    @objc func bqLoggerPresent(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        BQLogger.log("\(self) present \(viewControllerToPresent)")
        bqLoggerPresent(viewControllerToPresent, animated: flag, completion: completion)
    }
    
}

extension UINavigationController {
    @objc func bqLoggerPushViewController(_ viewController: UIViewController, animated: Bool) {
        BQLogger.log("\(self) push \(viewController)")
        bqLoggerPushViewController(viewController, animated: animated)
    }
}

extension UIViewController: ViewControllerLoggerProtocol {
    public static func startLifeCyclingLog() {
        guard UIApplication.isDebug else {
            BQLogger.log("current environment is debug can't log UIViewController life cycling")
            return
        }

        BQLogger.log("start UIViewController life cycling log")

        DispatchQueue.once(token: #function) {
            UIViewController.exchangeMethod(targetSel: #selector(viewDidLoad), newSel: #selector(bqLoggerViewDidLoad))
            UIViewController.exchangeMethod(targetSel: #selector(viewWillAppear), newSel: #selector(bqLoggerViewWillAppear))
            UIViewController.exchangeMethod(targetSel: #selector(viewWillDisappear), newSel: #selector(bqLoggerViewWillDisappear))
            UIViewController.exchangeMethod(targetSel: #selector(present), newSel: #selector(bqLoggerPresent))
            UINavigationController.exchangeMethod(targetSel: #selector(UINavigationController.pushViewController), newSel: #selector(UINavigationController.bqLoggerPushViewController))
        }
    }
}
