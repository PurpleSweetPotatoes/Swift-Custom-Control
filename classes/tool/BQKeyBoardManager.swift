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

// MARK: - BQKeyBoardManager

public class BQKeyBoardManager: NSObject {
    // MARK: Public

    public static func start(reView: UIView) {
        keyBoardManager.managerV = reView
        keyBoardManager.addNotification()
    }

    public static func close() {
        keyBoardManager.managerV = nil
        keyBoardManager.removeNotification()
    }

    // MARK: Private

    private var editVList = [UIView]()
    private var managerV: UIView?
    private var curV: UIView!
    private var didAdd = false

    // MARK: - Event

    @objc private func preBtnAction(sender _: UIButton) {
        if let index = editVList.firstIndex(of: curV) {
            let v = editVList[index - 1]
            v.becomeFirstResponder()
        }
    }

    @objc private func nextBtnAction(sender _: UIButton) {
        if let index = editVList.firstIndex(of: curV) {
            let v = editVList[index + 1]
            v.becomeFirstResponder()
        }
    }

    @objc private func dissBtnAction(sender _: UIButton) {
        curV.resignFirstResponder()
    }

    // MARK: - NotitfiCation

    private func addNotification() {
        editVList.removeAll()
        checkCanResponseV(reV: managerV!)
        for (index, subV) in editVList.enumerated() {
            if subV.inputAccessoryView == nil {
                let bar = BQKeyBoardToolBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
                bar.preBtn.addTarget(self, action: #selector(preBtnAction(sender:)), for: .touchUpInside)
                bar.nextBtn.addTarget(self, action: #selector(nextBtnAction(sender:)), for: .touchUpInside)
                bar.dissBtn.addTarget(self, action: #selector(dissBtnAction(sender:)), for: .touchUpInside)

                if index == 0 {
                    bar.preBtn.isSelected = true
                    bar.preBtn.isUserInteractionEnabled = false
                }

                if index == editVList.count - 1 {
                    bar.nextBtn.isUserInteractionEnabled = false
                    bar.nextBtn.isSelected = true
                }

                if let tf = subV as? UITextField {
                    tf.inputAccessoryView = bar
                } else if let tv = subV as? UITextView {
                    tv.inputAccessoryView = bar
                }
            }
        }

        if !didAdd {
            didAdd = true
            NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillDisplay), name: UITextField.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillDisplay), name: UITextField.keyboardDidShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillDismiss), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }

    private func removeNotification() {
        managerV = nil
        if didAdd {
            didAdd = false
            NotificationCenter.default.removeObserver(self)
        }
    }

    @objc private func keyBoardWillDisplay(notifi: Notification) {
        for editV in editVList {
            if editV.isFirstResponder, let userInfo = notifi.userInfo as? [String: Any] {
                curV = editV
                if let bar = editV.inputAccessoryView as? BQKeyBoardToolBar, let tf = editV as? UITextField {
                    bar.tipLab.text = tf.placeholder
                }
                // 回归原视图，这样不影响获取正确的视图最低点
                managerV?.transform = CGAffineTransform.identity
                let vRect = editV.superview?.convert(editV.frame, to: UIApplication.keyWindow)
                let vY = vRect?.maxY ?? 0.0
                // 获取键盘y值
                let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
                let keyBoardRect = value.cgRectValue
                let keyBoardHeight = keyBoardRect.size.height
                let keyBoardY = UIScreen.main.bounds.height - keyBoardHeight
                if keyBoardY < vY {
                    managerV?.transform = CGAffineTransform(translationX: 0, y: keyBoardY - vY)
                }
                return
            }
        }
    }

    @objc private func keyBoardWillDismiss(notifi _: Notification) {
        if let reV = managerV {
            reV.transform = CGAffineTransform.identity
        }
    }

    // MARK: - view Handle

    private func checkCanResponseV(reV: UIView) {
        for subV in reV.subviews {
            if subV is UITextField || subV is UITextView {
                editVList.append(subV)
            } else if !subV.subviews.isEmpty {
                checkCanResponseV(reV: subV)
            }
        }
    }
}

// MARK: - BQKeyBoardToolBar

class BQKeyBoardToolBar: UIView {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Fileprivate

    fileprivate var preBtn: UIButton!
    fileprivate var nextBtn: UIButton!
    fileprivate var dissBtn: UIButton!
    fileprivate var tipLab: UILabel!

    // MARK: Private

    func configUI() {
        backgroundColor = .systemGroupedBackground

        let preBtn = UIButton(type: .custom)
        preBtn.frame = CGRect(x: 10, y: 0, width: sizeH, height: sizeH)
        preBtn.setImage(UIImage.arrowImg(size: CGSize(width: 22, height: 12), color: .black, lineWidth: 2, direction: .top), for: .normal)
        preBtn.setImage(UIImage.arrowImg(size: CGSize(width: 22, height: 12), color: .lightGray, lineWidth: 2, direction: .top), for: .selected)
        addSubview(preBtn)
        self.preBtn = preBtn

        let nextBtn = UIButton(type: .custom)
        nextBtn.frame = CGRect(x: preBtn.frame.maxX, y: 0, width: sizeH, height: sizeH)
        nextBtn.setImage(UIImage.arrowImg(size: CGSize(width: 22, height: 12), color: .black, lineWidth: 2, direction: .bottom), for: .normal)
        nextBtn.setImage(UIImage.arrowImg(size: CGSize(width: 22, height: 12), color: .lightGray, lineWidth: 2, direction: .bottom), for: .selected)
        addSubview(nextBtn)
        self.nextBtn = nextBtn

        let lab = UILabel(frame: CGRect(x: 100, y: 0, width: sizeW - 160, height: sizeH), font: .systemFont(ofSize: 14), text: "", textColor: .black, alignment: .center)
        addSubview(lab)
        tipLab = lab

        let dissBtn = UIButton(type: .custom)
        dissBtn.frame = CGRect(x: sizeW - 60, y: 0, width: sizeH, height: sizeH)
        dissBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        dissBtn.setTitle("完成", for: .normal)
        dissBtn.setTitleColor(UIColor.mainColor, for: .normal)
        addSubview(dissBtn)
        self.dissBtn = dissBtn
    }
}
