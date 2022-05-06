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
    func bqLoggerViewDidAppear(_ animated: Bool)
    func bqLoggerViewWillDisappear(_ animated: Bool)
    func bqLoggerViewDidDisappear(_ animated: Bool)
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
    
    @objc func bqLoggerViewDidAppear(_ animated: Bool) {
        BQLogger.log("\(self) viewDidAppear")
        bqLoggerViewDidAppear(animated)
    }
    
    @objc func bqLoggerViewWillDisappear(_ animated: Bool) {
        BQLogger.log("\(self) viewWillDisappear")
        bqLoggerViewWillDisappear(animated)
    }
    
    @objc func bqLoggerViewDidDisappear(_ animated: Bool) {
        BQLogger.log("\(self) viewDidDisappear")
        bqLoggerViewDidDisappear(animated)
    }
    
    @objc func bqLoggerPresent(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        BQLogger.log("\(self) present \(viewControllerToPresent)")
        bqLoggerPresent(viewControllerToPresent, animated: flag, completion: completion)
    }
    
}

extension UINavigationController {
    @objc func bqLoggerPushViewController(_ viewController: UIViewController, animated: Bool) {
        BQLogger.log("\(self) present \(viewController)")
        bqLoggerPushViewController(viewController, animated: animated)
    }
}

//extension UIViewController: ViewControllerLoggerProtocol {}

