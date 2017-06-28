//
//  BQShowImgsView.swift
//  swift-Test
//
//  Created by MrBai on 2017/6/15.
//  Copyright © 2017年 MrBai. All rights reserved.
//

import UIKit

class BQShowImgsView: UIView, UIScrollViewDelegate {

    //MARK: - ***** Ivars *****
    private var selectInfo: Dictionary<String,Bool> = [:]
    private var imgArr: [UIImageView] = []
    private var backView: UIView = UIView(frame: UIScreen.main.bounds)
    private var animationView: UIImageView = UIImageView()
    private var toFrame: CGRect = CGRect.zero
    private var currentIndex: Int = 0
    private var contentView: UIScrollView = UIScrollView(frame: UIScreen.main.bounds)
    private var callBlock: (([Int]) -> ())?
    private let space:CGFloat = 20
    private let pageContrl = UIPageControl(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
    private let selectBtn = UIButton(type: .custom)
    //MARK: - ***** Class Method *****
    
    //MARK: - ***** initialize Method *****
    class func show(imgs:[UIImageView], current:Int = 0, deleteHandle: (([Int]) -> ())?){
        let view = BQShowImgsView(frame: UIScreen.main.bounds)
        view.currentIndex = current
        view.imgArr.append(contentsOf: imgs)
        view.callBlock = deleteHandle
        view.initUI()
        UIApplication.shared.keyWindow?.addSubview(view)
        UIView.animate(withDuration: 0.25, animations: {
            view.animationView.frame = view.toFrame
            view.backView.alpha = 1
        }) { (flag) in
            view.contentView.alpha = 1
            view.animationView.alpha = 0
            view.pageContrl.alpha = 1
            view.selectBtn.alpha = 1
        }
    }

    //MARK: - ***** public Method *****
    
    //MARK: - ***** private Method *****
    private func initUI() {
        self.backView.backgroundColor = UIColor.black
        self.backView.alpha = 0
        self.addSubview(self.backView)
        self.addSubview(self.contentView)
        self.contentView.alpha = 0
        self.contentView.delegate = self
        self.contentView.contentSize = CGSize(width: self.width * CGFloat(self.imgArr.count), height: self.height)
        self.contentView.addTapGes {[weak self] (view) in
            self?.removeSelf()
        }
        self.contentView.isPagingEnabled = true
        
        for index in 0 ..< self.imgArr.count {
            self.selectInfo[String(index)] = true
            let imgWith = self.width - space * 2
            let height = self.imgArr[index].image!.size.height * imgWith / self.imgArr[index].image!.size.width
            let imgView = UIImageView(frame: CGRect(x:space + CGFloat(index) * self.width, y: (self.height - height) * 0.5, width: imgWith, height: height))
            imgView.image = self.imgArr[index].image
            self.contentView.addSubview(imgView)
            if self.currentIndex == index {
                self.toFrame = CGRect(x: space, y: imgView.frame.origin.y, width: imgView.frame.width, height: imgView.frame.height)
            }
        }
        
        
        if self.callBlock == nil {
            self.selectBtn.isHidden = true
        }
        self.selectBtn.alpha = 0
        self.selectBtn.frame = CGRect(x: self.width - 70, y: 20, width: 50, height: 50)
        self.selectBtn.addTarget(self, action: #selector(showImgsBtnAction(btn:)), for: .touchUpInside)
        self.selectBtn.setImage(UIImage(named: "no_select"), for: .normal)
        self.selectBtn.setImage(UIImage(named: "select"), for: .selected)
        self.selectBtn.isSelected = true
        self.addSubview(self.selectBtn)
        
        self.pageContrl.center = CGPoint(x: self.center.x, y: self.height - 60)
        self.pageContrl.numberOfPages = self.imgArr.count
        self.pageContrl.alpha = 0
        self.addSubview(pageContrl)
        
        self.contentView.setContentOffset(CGPoint(x: CGFloat(self.currentIndex) * self.width, y: 0), animated: true)
        let imgView = self.imgArr[self.currentIndex]
        self.animationView.frame = imgView.superview!.convert(imgView.frame, to: UIApplication.shared.keyWindow?.rootViewController?.view)
        self.animationView.image = imgView.image
        self.addSubview(self.animationView)
    }
    private func removeSelf() {
        let imgView = self.imgArr[self.currentIndex]
        let imgWith = self.width - space * 2
        let height = imgView.image!.size.height * imgWith / imgView.image!.size.width
        self.animationView.frame = CGRect(x:space , y: (self.height - height) * 0.5, width: imgWith, height: height)
        self.animationView.image = self.imgArr[self.currentIndex].image
        self.toFrame = imgView.superview!.convert(imgView.frame, to: UIApplication.shared.keyWindow?.rootViewController?.view)
        self.animationView.alpha = 1
        self.contentView.alpha = 0
        self.pageContrl.alpha = 0
        self.selectBtn.alpha = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.animationView.frame = self.toFrame
            self.backView.alpha = 0
        }) { (flag) in
            self.animationView.alpha = 0
            self.removeFromSuperview()
            if let block = self.callBlock {
                var deletArr:[Int] = []
                for key in self.selectInfo.keys {
                    if !(self.selectInfo[key])! {
                        deletArr.append(Int(key)!)
                    }
                }
                block(deletArr)
            }
        }
    }
    private func changeStatus(scrollView:UIScrollView) {
        self.currentIndex = Int(scrollView.contentOffset.x / self.width)
        self.pageContrl.currentPage = self.currentIndex
        self.selectBtn.isSelected = self.selectInfo[String(self.currentIndex)]!
    }
    //MARK: - ***** LoadData Method *****
    
    //MARK: - ***** respond event Method *****
    @objc private func showImgsBtnAction(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        self.selectInfo[String(self.currentIndex)] = btn.isSelected
    }
    //MARK: - ***** Protocol *****
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.changeStatus(scrollView: scrollView)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.changeStatus(scrollView: scrollView)
    }
    //MARK: - ***** create Method *****

}
