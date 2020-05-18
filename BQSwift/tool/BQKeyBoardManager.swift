// *******************************************
//  File Name:      BQKeyBoardManager.swift       
//  Author:         MrBai
//  Created Date:   2020/5/13 4:37 PM
//    
//  Copyright © 2020 baiqiang
//  All rights reserved
// *******************************************
    

import UIKit

let keyBoardManager = BQKeyBoardManager()

class BQKeyBoardManager: NSObject {
    
    private var editVList = [UIView]()
    private var managerV: UIView?
    private var curV: UIView!
    private var didAdd = false
    
    public class func start(reView: UIView) -> Void {
        keyBoardManager.managerV = reView
        keyBoardManager.addNotification()
    }
    
    public class func close() {
        keyBoardManager.managerV = nil
        keyBoardManager.removeNotification()
    }
    
    // MARK: - Event
    
    @objc private func preBtnAction(sender: UIButton) -> Void {
        if let index = self.editVList.firstIndex(of: self.curV) {
            let v = self.editVList[index - 1]
            v.becomeFirstResponder()
        }
    }

    @objc private func nextBtnAction(sender: UIButton) -> Void {
        if let index = self.editVList.firstIndex(of: self.curV) {
            let v = self.editVList[index + 1]
            v.becomeFirstResponder()
        }
    }

    @objc private func dissBtnAction(sender: UIButton) -> Void {
        self.curV.resignFirstResponder()
    }
    // MARK: - NotitfiCation
    
    private func addNotification() -> Void {
        self.editVList.removeAll()
        self.checkCanResponseV(reV: self.managerV!)
        for (index, subV) in self.editVList.enumerated() {
            if subV.inputAccessoryView == nil {
                let bar = BQkeyBoardToolBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
                bar.preBtn.addTarget(self, action: #selector(preBtnAction(sender:)), for: .touchUpInside)
                bar.nextBtn.addTarget(self, action: #selector(nextBtnAction(sender:)), for: .touchUpInside)
                bar.dissBtn.addTarget(self, action: #selector(dissBtnAction(sender:)), for: .touchUpInside)
                
                if index == 0 {
                    bar.preBtn.isSelected = true
                    bar.preBtn.isUserInteractionEnabled = false;
                }
                
                if index == self.editVList.count - 1 {
                    bar.nextBtn.isUserInteractionEnabled = false;
                    bar.nextBtn.isSelected = true;
                }
                
                if let tf = subV as? UITextField {
                    tf.inputAccessoryView = bar
                } else if let tv = subV as? UITextView {
                    tv.inputAccessoryView = bar
                }
            }
        }
        
        if !self.didAdd {
            self.didAdd = true
            NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillDisplay), name: UITextField.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillDisplay), name: UITextField.keyboardDidShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillDismiss), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    private func removeNotification() -> Void {
        self.managerV = nil;
        if self.didAdd {
            self.didAdd = false
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    @objc private func keyBoardWillDisplay(notifi: Notification) -> Void {
        for editV in self.editVList {
            if editV.isFirstResponder, let userInfo = notifi.userInfo as? [String:Any] {
                self.curV = editV
                if let bar = editV.inputAccessoryView as? BQkeyBoardToolBar, let tf = editV as? UITextField {
                    bar.tipLab.text = tf.placeholder
                }
                //回归原视图，这样不影响获取正确的视图最低点
                self.managerV?.transform = CGAffineTransform.identity
                let vRect = editV.superview?.convert(editV.frame, to: UIApplication.shared.keyWindow)
                let vY = vRect?.maxY ?? 0.0
                //获取键盘y值
                let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
                let keyBoardRect = value.cgRectValue
                let keyBoardHeight = keyBoardRect.size.height
                let keyBoardY = UIScreen.main.bounds.height - keyBoardHeight
                if keyBoardY < vY {
                    self.managerV?.transform = CGAffineTransform(translationX: 0, y: keyBoardY - vY)
                }
                return
            }
        }
    }

    @objc private func keyBoardWillDismiss(notifi: Notification) {
        if let reV = self.managerV {
            reV.transform = CGAffineTransform.identity
        }
    }
 
    // MARK: - view Handle
    
    private func checkCanResponseV(reV: UIView) {
        for subV in reV.subviews {
            if subV is UITextField || subV is UITextView {
                self.editVList.append(subV)
            } else if subV.subviews.count != 0 {
                self.checkCanResponseV(reV: subV)
            }
        }
    }
}


class BQkeyBoardToolBar: UIView {
    
    fileprivate var preBtn: UIButton!
    fileprivate var nextBtn: UIButton!
    fileprivate var dissBtn: UIButton!
    fileprivate var tipLab: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() -> Void {
        self.backgroundColor = .groupTableViewBackground
        
        let preBtn = UIButton(type: .custom)
        preBtn.frame = CGRect(x: 10, y: 0, width: self.sizeH, height: self.sizeH)
        preBtn.setImage(UIImage.arrowImg(size: CGSize(width: 22, height: 12), color: .black, lineWidth: 2, direction: .top), for: .normal)
        preBtn.setImage(UIImage.arrowImg(size: CGSize(width: 22, height: 12), color: .lightGray, lineWidth: 2, direction: .top), for: .selected)
        self.addSubview(preBtn)
        self.preBtn = preBtn
        
        let nextBtn = UIButton(type: .custom)
        nextBtn.frame = CGRect(x: preBtn.frame.maxX, y: 0, width: self.sizeH, height: self.sizeH)
        nextBtn.setImage(UIImage.arrowImg(size: CGSize(width: 22, height: 12), color: .black, lineWidth: 2, direction: .bottom), for: .normal)
        nextBtn.setImage(UIImage.arrowImg(size: CGSize(width: 22, height: 12), color: .lightGray, lineWidth: 2, direction: .bottom), for: .selected)
        self.addSubview(nextBtn)
        self.nextBtn = nextBtn
        
        let lab = UILabel(frame: CGRect(x: 100, y: 0, width: self.sizeW - 160, height: self.sizeH), font: .systemFont(ofSize: 14), text: "", textColor: .black, alignment: .center)
        self.addSubview(lab)
        self.tipLab = lab
        
        let dissBtn = UIButton(type: .custom)
        dissBtn.frame = CGRect(x: self.sizeW - 60, y: 0, width: self.sizeH, height: self.sizeH)
        dissBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        dissBtn.setTitle("完成", for: .normal)
        dissBtn.setTitleColor(UIColor("0099ff"), for: .normal)
        self.addSubview(dissBtn)
        self.dissBtn = dissBtn
        
    }

}
