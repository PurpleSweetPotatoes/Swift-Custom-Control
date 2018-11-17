//
//  BQPopVc.swift
//  MyShortApp
//
//  Created by baiqiang on 2018/11/17.
//  Copyright © 2018年 baiqiang. All rights reserved.
//

import UIKit

typealias PopHandler = ((_ objc: Any?) -> Void)

class BQPopVc: UIViewController {
    
    var showTime: TimeInterval = 0.25
    var hideTime: TimeInterval = 0.25
    var dictInfo: Any?
    var handle:PopHandler?
    var backObjc: Any?
    
    /// if not need backView can removeFromSupView
    var backView: UIView = UIView(frame: UIScreen.main.bounds)
    
    public class func showView(presentVc: UIViewController, dictInfo:Any? = nil, handle:PopHandler? = nil) {
        let popVc = self.init()
        popVc.dictInfo = dictInfo
        popVc.handle = handle
        popVc.modalPresentationStyle = .overCurrentContext
        presentVc.present(popVc, animated: false) {
            popVc.animationShow()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        backView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        view.addSubview(backView)
        
        view.addTapGes {[weak self]  (tapView) in
            self?.handle = nil
            self?.animationHide()
        }
        
    }
    
    private func dismissSelf() {
        DispatchQueue.delay(0.2) {
            self.dismiss(animated: false) {[weak self] in
                if let hand = self?.handle {
                    hand(self?.backObjc)
                }
            }
        }
    }
    
    //MARK:- ***** subClass can override, need use super func *****
    func animationShow() {
        UIView.animate(withDuration: showTime) {
            self.backView.isHidden = false
        }
    }
    
    func animationHide() {
        if !backView.isHidden {
            UIView.animate(withDuration: hideTime, animations: {
                self.backView.isHidden = true;
            }) { (finished) in
                self.dismissSelf()
            }
        } else {
            DispatchQueue.delay(hideTime) {
                self.dismissSelf()
            }
        }
    }
    
}
