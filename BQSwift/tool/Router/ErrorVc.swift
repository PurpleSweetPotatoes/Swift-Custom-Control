//
//  ErrorVc.swift
//  Router-modular-demo
//
//  Created by baiqiang on 2017/6/10.
//  Copyright © 2017年 baiqiang. All rights reserved.
//

import UIKit

class ErrorVc: BaseVc {

    //MARK: - ***** Ivars *****
    private var label:UILabel!
    //MARK: - ***** Class Method *****
    
    //MARK: - ***** initialize Method *****
    
    //MARK: - ***** Lifecycle *****
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initUI()
        self.registerNotify()
    }
    
    //MARK: - ***** public Method *****

    //MARK: - ***** private Method *****
    private func initData() {
        self.navigationItem.title = "错误界面"
        self.view.backgroundColor = UIColor.white
    }
    private func initUI() {
        let label = UILabel(frame: CGRect(x: 100, y: 100, width: 200, height: 30))
        label.text = "无法找到该界面!"
        self.view.addSubview(label)
        self.label = label
    }
    private func registerNotify() {
        
    }
    //MARK: - ***** LoadData Method *****
    
    //MARK: - ***** respond event Method *****
    
    //MARK: - ***** Protocol *****
    
    //MARK: - ***** create Method *****

}
