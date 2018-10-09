//
//  BaseVc.swift
//  RouterDemo
//
//  Created by baiqiang on 2017/6/11.
//  Copyright © 2017年 baiqiang. All rights reserved.
//

import UIKit 

class BaseVc: UIViewController,BQRouterCommProtocol {
    //MARK: - ***** Ivars *****
    var removeIndex: Int = -1
    //MARK: - ***** Class Method *****
    
    //MARK: - ***** initialize Method *****
    
    //MARK: - ***** Lifecycle *****
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initUI()
        self.registerNotify()
    }
    deinit {
        print("\(self) is destroy")
        NotificationCenter.default.removeObserver(self)
        BQRouterComm.romveRouterComm(target: self)
    }
    //MARK: - ***** public Method *****
    
    //MARK: - ***** private Method *****
    private func initData() {
        self.view.backgroundColor = UIColor.white
    }
    private func initUI() {
        
        if self.navigationController?.viewControllers.index(of: self) != 0 {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(leftbackItemAction))
        }
    }
    private func registerNotify() {
        
    }
    //MARK: - ***** LoadData Method *****
    
    //MARK: - ***** respond event Method *****
    @objc private func leftbackItemAction() {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: - ***** Protocol *****
    func loadVcInfo(params:Any) {
        print("空方法")
    }
    func reciveRouterComm(name: Notification.Name, params: Any?) {
        print("空方法")
    }
    //MARK: - ***** create Method *****

}
