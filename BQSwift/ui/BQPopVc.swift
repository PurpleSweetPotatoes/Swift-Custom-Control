// *******************************************
//  File Name:      BQPopVc.swift       
//  Author:         MrBai
//  Created Date:   2019/8/19 4:53 PM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************
    

import UIKit

open class BQPopVc: UIViewController {

    // MARK: - var
    open var showTime: TimeInterval = 0.25
    open var hideTime: TimeInterval = 0.25
    public var showBgView: Bool = true {
        didSet {
            backView.isHidden = !showBgView
        }
    }
    
    private let backView: UIView = UIView(frame: UIScreen.main.bounds)
    // MARK: - create
    
    open class func showView(presentVc: UIViewController) {
        let popVc = self.init()
        presentVc.present(popVc, animated: false) {
            popVc.show()
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .overCurrentContext
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - life
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.configUI()
    }
    // MARK: - public method
    
    open func showView(presentVc: UIViewController) {
        presentVc.present(self, animated: false) {
            self.show()
        }
    }
    
    open func didDisMiss() {
        print("完成移除")
    }
    
    open func animationShow() {
        
    }
    
    open func animationHide() {
        
    }
    
    
    // MARK: - private method
    
    private func dismissSelf() {
        DispatchQueue.delay(0.2) {
            self.dismiss(animated: false) {[weak self] in
                self?.didDisMiss()
            }
        }
    }
    
    private func show() {
        if showBgView {
            UIView.animate(withDuration: showTime) {
                self.backView.isHidden = false
            }
        }
        self.animationShow()
    }
    
    private func hide() {
        if showBgView {
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
        self.animationHide()
    }
    
    // MARK: - UI method
    private func configUI() {
        backView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        view.addSubview(backView)
        
        view.addTapGes {[weak self]  (tapView) in
            self?.hide()
        }
    }

}
