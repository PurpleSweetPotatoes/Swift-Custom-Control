//
//  BQImagesPickView.swift
//  swift-Test
//
//  Created by MrBai on 2017/6/15.
//  Copyright © 2017年 MrBai. All rights reserved.
//

import UIKit

enum ImagesPickType {
    case one
    case more
}

protocol ImagesPick {
    func pickImage(img: UIImage)
    func deleteImage(indexArr:[Int])
    func pickMoreImage(imgs:[UIImage])
}

extension ImagesPick {
    func pickImage(img: UIImage) {}
    func deleteImage(indexArr:[Int]){}
    func pickMoreImage(imgs:[UIImage]){}
}

class BQImagesPickView: UIView {

    //MARK: - ***** Ivars *****
    
    
    /// when addType is one can be used
    var clipType: ClipSizeType = .none
    var pickDelegate: ImagesPick?
    var imageArr: [UIImage] {
        get {
            var imgs:[UIImage] = []
            for imgView in self.imgViewArr {
                imgs.append(imgView.image!)
            }
            return imgs
        }
    }
    var spacing: CGFloat = 10 {
        didSet {
            self.adjsutSubView()
        }
    }
    
    private var lineNum: Int = 0
    private var addType: ImagesPickType = .one
    private var imgWidth: CGFloat = 0
    private var imgHeight: CGFloat = 0
    private let addBtn: UIButton = UIButton(type: .custom)
    private var imgViewArr: [UIImageView] = []
    
    //MARK: - ***** Class Method *****
    
    //MARK: - ***** initialize Method *****
    convenience init(frame: CGRect, lineNum:Int = 4) {
        self.init(frame: frame, addImage: nil, lineNum: lineNum)
    }
    convenience init(frame: CGRect, addImage:UIImage, addType: ImagesPickType, lineNum:Int = 4) {
        self.init(frame: frame, addImage: addImage, lineNum: lineNum, addType: addType)
    }
    private init(frame: CGRect, addImage:UIImage? , lineNum:Int = 4, addType: ImagesPickType = .one) {
        super.init(frame: frame)
        self.lineNum = lineNum
        self.addType = addType
        if let image = addImage {
            self.addBtn.setBackgroundImage(image, for: .normal)
        }else {
            self.addBtn.isHidden = true
        }
        self.initData()
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - ***** public Method *****
    func setUrls(imgs:[String]) {
        self.clearImgs()
        for str in imgs {
            let imgView = self.creatImgView()
            imgView.setImage(urlStr: str)
        }
        self.adjsutSubView()
    }
    func setImgs(imgs:[UIImage]){
        self.clearImgs()
        for img in imgs {
            let imgView = self.creatImgView()
            imgView.image = img
        }
        self.adjsutSubView()
    }
    func clearImgs() {
        for view in self.imgViewArr {
            view.removeFromSuperview()
        }
        self.imgViewArr.removeAll()
        self.adjsutSubView()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    //MARK: - ***** private Method *****
    private func initData() {
        self.imgWidth = (self.bounds.width - self.spacing) / CGFloat(self.lineNum) - self.spacing
        self.imgHeight = self.imgWidth
        if self.addType == .one {
            switch self.clipType {
            case .twoScaleOne:
                self.imgHeight = self.imgWidth * 0.5
            case .threeScaleTwo:
                self.imgHeight = self.imgHeight * 2 / 3
            default:
                break
            }
        }
    }
    private func initUI() {
        self.backgroundColor = UIColor.white
        self.addBtn.addTarget(self, action: #selector(addBtnAction), for: .touchUpInside)
        self.addSubview(self.addBtn)
        self.adjsutSubView()
    }
    private func adjsutSubView() {
        let space = self.spacing
        var frame: CGRect = CGRect.zero
        for index in 0 ..< self.imgViewArr.count {
            frame = CGRect(x: space + (self.imgWidth + space) * CGFloat(index % self.lineNum), y: space + CGFloat(index / self.lineNum) * (self.imgHeight + space), width: self.imgWidth, height: self.imgHeight)
            self.imgViewArr[index].frame = frame
        }
        if !self.addBtn.isHidden {
            let index = self.imgViewArr.count
            frame = CGRect(x: space + (self.imgWidth + space) * CGFloat(index % self.lineNum), y: space + CGFloat(index / self.lineNum) * (self.imgHeight + space), width: self.imgWidth, height: self.imgHeight)
            self.addBtn.frame = frame
        }
        
        self.height = frame.maxY + space
    }
    private func creatImgView() -> UIImageView {
        let imgView = UIImageView()
        imgView.addTapGes {[weak self] (imgV) in
            self?.tapImgAction(imgView: imgV as! UIImageView)
        }
        self.imgViewArr.append(imgView)
        self.addSubview(imgView)
        return imgView
    }
    private func tapImgAction(imgView:UIImageView) {
        let index = self.imgViewArr.index(of: imgView)!
        if self.addBtn.isHidden {
            BQPhotoBrowserView.show(datas: self.imgViewArr, current: index)
        }else {
            BQShowImgsView.show(imgs: self.imgViewArr,current: index, deleteHandle: {[weak self] (deletArr) in
                let arr = deletArr.sorted(by: {$0 > $1})
                for index in  arr {
                    self?.imgViewArr[index].removeFromSuperview()
                    self?.imgViewArr.remove(at: index)
                }
                self?.adjsutSubView()
                if let delegate = self?.pickDelegate {
                    delegate.deleteImage(indexArr: arr)
                }
            })
        }
    }
    //MARK: - ***** LoadData Method *****
    
    //MARK: - ***** respond event Method *****
    @objc private func addBtnAction() {
        if self.addType == .one {
            BQImagePicker.showPicker(type: self.clipType, handle: {[weak self] (image) in
                if let delegate = self?.pickDelegate {
                    delegate.pickImage(img: image)
                }
                let imgView = self?.creatImgView()
                imgView?.image = image
                self?.adjsutSubView()
            })
        }else {
            print("多选")
        }
    }
    //MARK: - ***** Protocol *****
    
    //MARK: - ***** create Method *****

}
