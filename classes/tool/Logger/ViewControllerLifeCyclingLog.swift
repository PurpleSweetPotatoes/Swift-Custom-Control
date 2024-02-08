// *******************************************
//  File Name:      ViewControllerLifeCyclingLog.swift
//  Author:         MrBai
//  Created Date:   2022/4/30 13:09
//
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import UIKit

extension UIViewController {
    @objc func bqLoggerViewWillAppear(_ animated: Bool) {
        print("\(self) ViewWillAppear")
        bqLoggerViewWillAppear(animated)
    }

    @objc func bqLoggerViewWillDisappear(_ animated: Bool) {
        print("\(self) viewWillDisappear")
        bqLoggerViewWillDisappear(animated)
    }

    @objc func bqLoggerPresent(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        print("\(self) present \(viewControllerToPresent)")
        bqLoggerPresent(viewControllerToPresent, animated: flag, completion: completion)
    }

    @discardableResult
    public static func startLifeCyclingLog() -> Bool {
        guard isDebug else {
            print("current environment is debug can't log UIViewController life cycling")
            return false
        }
        print("start UIViewController life cycling log")

        UIViewController.exchangeMethodImp(targetSel: #selector(UIViewController.viewWillAppear(_:)), newSel: #selector(UIViewController.bqLoggerViewWillAppear(_:)))
        UIViewController.exchangeMethodImp(targetSel: #selector(UIViewController.viewWillDisappear(_:)), newSel: #selector(UIViewController.bqLoggerViewWillDisappear(_:)))
        UIViewController.exchangeMethodImp(targetSel: #selector(UIViewController.present(_:animated:completion:)), newSel: #selector(UIViewController.bqLoggerPresent(_:animated:completion:)))
        UINavigationController.exchangeMethodImp(targetSel: #selector(UINavigationController.pushViewController(_:animated:)), newSel: #selector(UINavigationController.bqLoggerPushViewController(_:animated:)))
        return true
    }

    @discardableResult
    static func exchangeMethodImp(targetSel: Selector, newSel: Selector) -> Bool {
        guard let before: Method = class_getInstanceMethod(self, targetSel),
              let after: Method = class_getInstanceMethod(self, newSel)
        else {
            return false
        }

        if class_addMethod(self, targetSel, method_getImplementation(after), method_getTypeEncoding(after)) {
            class_replaceMethod(self, newSel, method_getImplementation(before), method_getTypeEncoding(before))
        } else {
            method_exchangeImplementations(before, after)
        }
        return true
    }

    /// Selected debugger executable at scheme info will return true
    static var isDebug: Bool {
        // Initialize all the fields so that,
        // if sysctl fails for some bizarre reason, we get a predictable result.
        var info = kinfo_proc()
        // Initialize mib, which tells sysctl the info we want,
        // in this case we're looking for info about a specific process ID.
        var mib = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        // Call sysctl.
        var size = MemoryLayout.stride(ofValue: info)
        let junk = sysctl(&mib, u_int(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        // We're being debugged if the P_TRACED flag is set.
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
}

extension UINavigationController {
    @objc func bqLoggerPushViewController(_ viewController: UIViewController, animated: Bool) {
        print("\(self) push \(viewController)")
        bqLoggerPushViewController(viewController, animated: animated)
    }
}
