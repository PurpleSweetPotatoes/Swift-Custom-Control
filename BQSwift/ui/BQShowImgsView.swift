//
//  BQShowImgsView.swift
//  swift-Test
//
//  Created by MrBai on 2017/6/15.
//  Copyright © 2017年 MrBai. All rights reserved.
//

import UIKit

class BQShowImgsView: UIView, UIScrollViewDelegate {
    // MARK: - ***** Ivars *****

    private var selectInfo: [String: Bool] = [:]
    private var imgArr: [UIImageView] = []
    private var backView = UIView(frame: UIScreen.main.bounds)
    private var animationView = UIImageView()
    private var toFrame = CGRect.zero
    private var currentIndex: Int = 0
    private var contentView = UIScrollView(frame: UIScreen.main.bounds)
    private var callBlock: (([Int]) -> Void)?
    private let space: CGFloat = 20
    private let pageContrl = UIPageControl(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
    private let selectBtn = UIButton(type: .custom)

    // MARK: - ***** Class Method *****

    // MARK: - ***** initialize Method *****

    class func show(imgs: [UIImageView], current: Int = 0, deleteHandle: (([Int]) -> Void)?) {
        let view = BQShowImgsView(frame: UIScreen.main.bounds)
        view.currentIndex = current
        view.imgArr.append(contentsOf: imgs)
        view.callBlock = deleteHandle
        view.initUI()
        UIApplication.shared.keyWindow?.addSubview(view)
        UIView.animate(withDuration: 0.25, animations: {
            view.animationView.frame = view.toFrame
            view.backView.alpha = 1
        }) { _ in
            view.contentView.alpha = 1
            view.animationView.alpha = 0
            view.pageContrl.alpha = 1
            view.selectBtn.alpha = 1
        }
    }

    // MARK: - ***** public Method *****

    // MARK: - ***** private Method *****

    private func initUI() {
        backView.backgroundColor = UIColor.black
        backView.alpha = 0
        addSubview(backView)
        addSubview(contentView)
        contentView.alpha = 0
        contentView.delegate = self
        contentView.contentSize = CGSize(width: sizeW * CGFloat(imgArr.count), height: sizeH)
        contentView.addTapGes { [weak self] _ in
            self?.removeSelf()
        }
        contentView.isPagingEnabled = true

        for index in 0 ..< imgArr.count {
            selectInfo[String(index)] = true
            let imgWith = sizeW - space * 2
            let height = imgArr[index].image!.size.height * imgWith / imgArr[index].image!.size.width
            let imgView = UIImageView(frame: CGRect(x: space + CGFloat(index) * sizeW, y: (sizeH - height) * 0.5, width: imgWith, height: height))
            imgView.image = imgArr[index].image
            contentView.addSubview(imgView)
            if currentIndex == index {
                toFrame = CGRect(x: space, y: imgView.frame.origin.y, width: imgView.frame.width, height: imgView.frame.height)
            }
        }

        if callBlock == nil {
            selectBtn.isHidden = true
        }
        selectBtn.alpha = 0
        selectBtn.frame = CGRect(x: sizeW - 70, y: 20, width: 50, height: 50)
        selectBtn.addTarget(self, action: #selector(showImgsBtnAction(btn:)), for: .touchUpInside)
        selectBtn.setImage(UIImage(named: "no_select"), for: .normal)
        selectBtn.setImage(UIImage(named: "select"), for: .selected)
        selectBtn.isSelected = true
        addSubview(selectBtn)

        pageContrl.center = CGPoint(x: center.x, y: sizeH - 60)
        pageContrl.numberOfPages = imgArr.count
        pageContrl.alpha = 0
        addSubview(pageContrl)

        contentView.setContentOffset(CGPoint(x: CGFloat(currentIndex) * sizeW, y: 0), animated: true)
        let imgView = imgArr[currentIndex]
        animationView.frame = imgView.superview?.convert(imgView.frame, to: UIApplication.shared.keyWindow?.rootViewController?.view) ?? CGRect.zero
        animationView.image = imgView.image
        addSubview(animationView)
    }

    private func removeSelf() {
        let imgView = imgArr[currentIndex]
        let imgWith = sizeW - space * 2
        let height = imgView.image!.size.height * imgWith / imgView.image!.size.width
        animationView.frame = CGRect(x: space, y: (sizeH - height) * 0.5, width: imgWith, height: height)
        animationView.image = imgArr[currentIndex].image
        toFrame = imgView.superview?.convert(imgView.frame, to: UIApplication.shared.keyWindow?.rootViewController?.view) ?? CGRect.zero
        animationView.alpha = 1
        contentView.alpha = 0
        pageContrl.alpha = 0
        selectBtn.alpha = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.animationView.frame = self.toFrame
            self.backView.alpha = 0
        }) { _ in
            self.animationView.alpha = 0
            self.removeFromSuperview()
            if let block = self.callBlock {
                var deletArr: [Int] = []
                for key in self.selectInfo.keys {
                    if !(self.selectInfo[key])! {
                        deletArr.append(Int(key)!)
                    }
                }
                block(deletArr)
            }
        }
    }

    private func changeStatus(scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / sizeW)
        pageContrl.currentPage = currentIndex
        selectBtn.isSelected = selectInfo[String(currentIndex)]!
    }

    // MARK: - ***** LoadData Method *****

    // MARK: - ***** respond event Method *****

    @objc private func showImgsBtnAction(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        selectInfo[String(currentIndex)] = btn.isSelected
    }

    // MARK: - ***** Protocol *****

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        changeStatus(scrollView: scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        changeStatus(scrollView: scrollView)
    }

    // MARK: - ***** create Method *****
}
