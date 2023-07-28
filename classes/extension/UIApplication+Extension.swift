//
//  UIApplication+Extension.swift
//  Pods
//  
//  Created by Bai, Payne on 2023/3/12.
//  Copyright © 2023 Garmin All rights reserved
//  

import UIKit

public extension UIApplication {

    static var keyWindow: UIWindow? {
        UIApplication.shared
            .connectedScenes
            .first(where: { $0 is UIWindowScene })
            .flatMap { $0 as? UIWindowScene }?.windows
            .first(where: \.isKeyWindow)
    }

    static var statusBarHeight: CGFloat {
        keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }

    static var width: CGFloat {
        UIApplication.shared
            .connectedScenes
            .first(where: { $0 is UIWindowScene })
            .flatMap { $0 as? UIWindowScene }?.windows
            .first(where: \.isKeyWindow)?.screen.bounds.width ?? 0
    }

    static var height: CGFloat {
        UIApplication.shared
            .connectedScenes
            .first(where: { $0 is UIWindowScene })
            .flatMap { $0 as? UIWindowScene }?.windows
            .first(where: \.isKeyWindow)?.screen.bounds.height ?? 0
    }

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

    static func goPermissionSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }
}
