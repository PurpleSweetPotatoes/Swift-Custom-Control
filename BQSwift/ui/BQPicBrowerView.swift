// *******************************************
//  File Name:      BQPicBrowerView.swift
//  Author:         MrBai
//  Created Date:   2021/7/31 8:40 PM
//
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import UIKit

protocol BQPicBrowerViewDelegate: NSObjectProtocol {
    func didShowImgV(imgV: UIImageView, index: Int)
    func willShowImgV(imgV: UIImageView, index: Int)
    func changeCurrentIndex(index: Int)
    func scrollerToFront()
    func scrollerToNext()
}

extension BQPicBrowerViewDelegate {
    func willShowImgV(imgV _: UIImageView, index _: Int) {}
    func changeCurrentIndex(index _: Int) {}
    func scrollerToFront() {}
    func scrollerToNext() {}
}

class BQPicBrowerView: UIView {
    private var collectionView: UICollectionView!
    public var imgCount: Int = 0
    public var delegate: BQPicBrowerViewDelegate?
    private var currentIndex: Int = 0
    private var isLeft = false
    private var isRight = false

    // MARK: - *** Ivars

    // MARK: - *** Public method

    public func scorllerTo(_ index: Int) {
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
    }

    public func reloadData() {
        collectionView.reloadData()
        collectionView.setContentOffset(CGPoint.zero, animated: false)
    }

    // MARK: - *** Life cycle

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - *** NetWork method

    // MARK: - *** Event Action

    // MARK: - *** Delegate

    // MARK: - *** Instance method

    // MARK: - *** UI method

    private func configUI() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        collectionView.isPrefetchingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.register(PicCollectionCell.classForCoder(), forCellWithReuseIdentifier: "identifi")
        addSubview(collectionView)
    }
}

extension BQPicBrowerView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return imgCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "identifi", for: indexPath) as! PicCollectionCell
        cell.row = indexPath.item
        callDelegate(isDid: true, cell: cell)
        return cell
    }

    func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt _: IndexPath) {
        let photoCell = cell as! PicCollectionCell
        callDelegate(isDid: false, cell: photoCell)
    }

    func callDelegate(isDid: Bool, cell: PicCollectionCell) {
        cell.photoView.zoomNormal()
        if let call = delegate {
            let imgV = cell.photoView.imageView

            if isDid {
                call.didShowImgV(imgV: imgV, index: cell.row)
            } else {
                call.willShowImgV(imgV: imgV, index: cell.row)
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let x = Int(scrollView.contentOffset.x + scrollView.sizeW * 0.5)
        let w = Int(scrollView.sizeW)
        let index = x / w
        if let call = delegate, index != currentIndex {
            currentIndex = index
            call.changeCurrentIndex(index: index)
        }
        if imgCount > 0 {
            if scrollView.contentOffset.x + scrollView.sizeW > scrollView.sizeW * CGFloat(imgCount) + 40 {
                if !isRight {
                    isRight = true
                    delegate?.scrollerToNext()
                }
            } else {
                isRight = false
            }

            if scrollView.contentOffset.x < -40 {
                if !isLeft {
                    isLeft = true
                    delegate?.scrollerToFront()
                }
            } else {
                isLeft = false
            }
        }
    }
}

class PicCollectionCell: UICollectionViewCell {
    fileprivate var photoView: BQPhotoView!

    var row: Int = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        photoView = BQPhotoView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        photoView.contentMode = .scaleAspectFit
        contentView.addSubview(photoView)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
