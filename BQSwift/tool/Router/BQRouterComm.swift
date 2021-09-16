//
//  BQRouterComm.swift
//  Router-modular-demo
//
//  Created by baiqiang on 2017/6/29.
//  Copyright © 2017年 baiqiang. All rights reserved.
//

import UIKit

public extension Notification.Name {
    static let RLoginSucess = NSNotification.Name("RLoginSucess")
    static let RLogout = NSNotification.Name("RLogout")
}

protocol BQRouterCommProtocol: NSObjectProtocol {
    var removeIndex: Int { get set }
    func loadVcInfo(params: Any)
    func reciveRouterComm(name: Notification.Name, params: Any?)
}

class BQRouterComm {
    // MARK: - --- private Ivar

    private static let share = BQRouterComm()
    private var commObjcs: [BaseVcProxy] = []

    // MARK: - --- public Method

    public class func addRouterComm(names: Notification.Name..., target: BQRouterCommProtocol) {
        share.addComm(names: names, target: target)
    }

    public class func postRouterComm(name: Notification.Name, params: Any? = nil) {
        share.postComm(name: name, params: params)
    }

    public class func romveRouterComm(target: BQRouterCommProtocol) {
        share.removeComm(target: target)
    }

    // MARK: - --- private Method

    private func addComm(names: [Notification.Name], target: BQRouterCommProtocol) {
        for weakVc in commObjcs {
            if let vc = weakVc.vc {
                if (vc as! UIViewController) == (target as! UIViewController) {
                    return
                }
            }
        }
        let weakVc = BaseVcProxy(vc: target)
        weakVc.notifiArr.append(contentsOf: names)
        commObjcs.append(weakVc)
        target.removeIndex = commObjcs.firstIndex(of: weakVc)!
    }

    private func postComm(name: Notification.Name, params: Any?) {
        for weakVc in commObjcs {
            if let vc = weakVc.vc {
                if weakVc.notifiArr.contains(name) {
                    vc.reciveRouterComm(name: name, params: params)
                }
            }
        }
    }

    private func removeComm(target: BQRouterCommProtocol) {
        if target.removeIndex >= 0 {
            commObjcs.remove(at: target.removeIndex)
        }
        print(commObjcs)
    }

    private init() {}
}

class BaseVcProxy: NSObject {
    weak var vc: BQRouterCommProtocol?
    var notifiArr: [Notification.Name] = []
    init(vc: BQRouterCommProtocol) {
        self.vc = vc
        super.init()
    }
}
