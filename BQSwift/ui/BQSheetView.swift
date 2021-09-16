// *******************************************
//  File Name:      BQSheetView.swift
//  Author:         MrBai
//  Created Date:   2019/8/20 2:50 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

enum SheetType {
    case table
    case collection
}

class BQSheetView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: - ***** Ivars *****

    private var title: String?
    private var type: SheetType!
    private var tableDatas: [String] = []
    private var shareDatas: [[String: String]] = []
    private var backView: UIView!
    private var bottomView: UIView!
    private var callBlock: ((Int) -> Void)!

    // MARK: - ***** Class Method *****

    /// 脚部弹出视图
    ///
    /// - Parameters:
    ///   - tableDatas: 数据信息
    ///   - title: 标题
    ///   - handle: 回调
    class func showSheetView(tableDatas: [String], title: String? = nil, handle: @escaping (Int) -> Void) {
        let sheetView = BQSheetView(tableDatas: tableDatas, title: title)
        sheetView.callBlock = handle
        UIApplication.shared.keyWindow?.addSubview(sheetView)
        sheetView.startAnimation()
    }

    /// 弹出脚部分享视图
    ///
    /// - Parameters:
    ///   - shareDatas: ["image":"图片名"]
    ///   - title: 抬头名称
    ///   - handle: 回调方法
    class func showShareView(shareDatas: [[String: String]], title: String, handle: @escaping (Int) -> Void) {
        let sheetView = BQSheetView(shareDatas: shareDatas, title: title)
        sheetView.callBlock = handle
        UIApplication.shared.keyWindow?.addSubview(sheetView)
        sheetView.startAnimation()
    }

    // MARK: - ***** initialize Method *****

    private init(tableDatas: [String], title: String? = nil) {
        self.title = title
        type = .table
        self.tableDatas = tableDatas
        super.init(frame: UIScreen.main.bounds)
        initData()
        initUI()
    }

    private init(shareDatas: [[String: String]], title: String? = nil) {
        self.title = title
        type = .collection
        self.shareDatas = shareDatas
        super.init(frame: UIScreen.main.bounds)
        initData()
        initUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ***** public Method *****

    // MARK: - ***** private Method *****

    private func initData() {}

    private func initUI() {
        backView = UIView(frame: bounds)
        backView.backgroundColor = UIColor(white: 0.5, alpha: 0.4)
        backView.alpha = 0

        backView.addTapGes { [weak self] _ in
            self?.removeAnimation()
        }
        addSubview(backView)

        bottomView = UIView(frame: CGRect(x: 0, y: sizeH, width: sizeW, height: 0))
        addSubview(bottomView)

        var top: CGFloat = 0

        if type == .table {
            top = createTableUI(y: top)
        } else {
            top = createShareUI(y: top)
        }
        bottomView.sizeH = top + 8
    }

    private func startAnimation() {
        UIView.animate(withDuration: 0.25) {
            self.bottomView.top = self.sizeH - self.bottomView.sizeH
            self.backView.alpha = 1
        }
    }

    private func removeAnimation() {
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomView.top = self.sizeH
            self.backView.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }

    // MARK: - ***** LoadData Method *****

    // MARK: - ***** respond event Method *****

    @objc private func tableBtnAction(btn: UIButton) {
        callBlock(btn.tag)
        removeAnimation()
    }

    // MARK: - ***** Protocol *****

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return shareDatas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BQShareItemCell", for: indexPath) as! BQShareItemCell
        cell.loadInfo(dic: shareDatas[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        callBlock(indexPath.row)
        removeAnimation()
    }

    // MARK: - ***** create Method *****

    private func createTableUI(y: CGFloat) -> CGFloat {
        var top = y
        let spacing: CGFloat = 20
        let height: CGFloat = 44
        let labWidth: CGFloat = sizeW - spacing * 2
        if let title = self.title {
            top = setUpTitleLabel(title: title, frame: CGRect(x: spacing, y: top, width: labWidth, height: height))
        }

        top += 1
        for (index, str) in tableDatas.enumerated() {
            let btn = UIButton(type: .custom)
            btn.frame = CGRect(x: spacing, y: top, width: labWidth, height: height)
            btn.setTitle(str, for: .normal)
            btn.tag = index
            btn.titleLabel?.textAlignment = .center
            btn.backgroundColor = UIColor.white
            btn.setTitleColor(UIColor.black, for: .normal)
            btn.addTarget(self, action: #selector(tableBtnAction(btn:)), for: .touchUpInside)
            bottomView.addSubview(btn)
            top = btn.bottom + 1
        }
        top += 7
        let lab = UILabel(frame: CGRect(x: spacing, y: top, width: labWidth, height: height))
        lab.text = "返回"
        lab.layer.cornerRadius = 8
        lab.layer.masksToBounds = true
        lab.textAlignment = .center
        lab.backgroundColor = UIColor.white
        lab.addTapGes(action: { [weak self] _ in
            self?.removeAnimation()
        })
        bottomView.addSubview(lab)
        return lab.bottom
    }

    private func createShareUI(y: CGFloat) -> CGFloat {
        var top = y
        let spacing: CGFloat = 10
        let labWidth: CGFloat = sizeW - spacing * 2
        let itemWidth = labWidth / 4.0
        if let title = self.title {
            top = setUpTitleLabel(title: title, frame: CGRect(x: spacing, y: top, width: labWidth, height: 20))
        }
        top += 1
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.scrollDirection = .vertical
        var num = shareDatas.count / 4
        if shareDatas.count % 4 > 0 {
            num += 1
        }
        let collectionView = UICollectionView(frame: CGRect(x: spacing, y: top, width: labWidth, height: CGFloat(num) * itemWidth), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(BQShareItemCell.classForCoder(), forCellWithReuseIdentifier: "BQShareItemCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        bottomView.addSubview(collectionView)
        top = collectionView.bottom + 1
        let lab = UILabel(frame: CGRect(x: spacing, y: top, width: labWidth, height: 44))
        lab.backgroundColor = UIColor.white
        lab.text = "返回"
        lab.textAlignment = .center
        lab.addTapGes(action: { [weak self] _ in
            self?.removeAnimation()
        })
        bottomView.addSubview(lab)
        return lab.bottom
    }

    private func setUpTitleLabel(title: String, frame: CGRect) -> CGFloat {
        let lab = UILabel(frame: frame)
        lab.backgroundColor = UIColor.white
        lab.text = title
        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = UIColor.gray
        lab.adjustHeight(spacing: 20)

        bottomView.addSubview(lab)

        return lab.sizeH
    }
}

class BQShareItemCell: UICollectionViewCell {
    private var imgView: UIImageView!
    private var titleLab: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func initUI() {
        let imgWidth = sizeW / 2.0
        let spacing = (sizeW - imgWidth) * 0.5
        let imageView = UIImageView(frame: CGRect(x: spacing, y: spacing * 0.7, width: imgWidth, height: imgWidth))
        contentView.addSubview(imageView)
        imgView = imageView

        let lab = UILabel(frame: CGRect(x: 0, y: imageView.bottom, width: sizeW, height: spacing))
        lab.textAlignment = .center
        lab.font = UIFont.systemFont(ofSize: 13)
        lab.textColor = UIColor.gray
        contentView.addSubview(lab)
        titleLab = lab
    }

    public func loadInfo(dic: [String: String]) {
        imgView.image = UIImage(named: dic["image"] ?? "")
        titleLab.text = dic["image"]
    }
}
