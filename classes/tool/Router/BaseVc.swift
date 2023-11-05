//
//  BaseVc.swift
//  RouterDemo
//
//  Created by baiqiang on 2017/6/11.
//  Copyright © 2017年 baiqiang. All rights reserved.
//

import UIKit

class BaseVc: UIViewController, BQRouterCommProtocol {
    // MARK: - ***** Ivars *****

    var removeIndex: Int = -1

    // MARK: - ***** Class Method *****

    // MARK: - ***** initialize Method *****

    // MARK: - ***** Lifecycle *****

    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
        registerNotify()
    }

    deinit {
        BQLogger.log("\(self) is destroy")
        NotificationCenter.default.removeObserver(self)
        BQRouterComm.romveRouterComm(target: self)
    }

    // MARK: - ***** public Method *****

    // MARK: - ***** private Method *****

    private func initData() {
        view.backgroundColor = UIColor.white
    }

    private func initUI() {
        if navigationController?.viewControllers.firstIndex(of: self) != 0 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(leftbackItemAction))
        }
    }

    private func registerNotify() {}

    // MARK: - ***** LoadData Method *****

    // MARK: - ***** respond event Method *****

    @objc private func leftbackItemAction() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - ***** Protocol *****

    func loadVcInfo(params _: Any) {}

    func reciveRouterComm(name _: Notification.Name, params _: Any?) {}

    // MARK: - ***** create Method *****
}
