// *******************************************
//  File Name:      BQPhotoBrowserView.swift
//  Author:         MrBai
//  Created Date:   2019/8/20 2:38 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

private let identifi = "BQPhotoCollectionDisPlayCell"

protocol BQPhotoBrowserViewDelegate: NSObjectProtocol {
    func startAnimationFromFrame(currentIndex: Int) -> CGRect?
    func removeAnimationToFrame(currentIndex: Int) -> CGRect?
}

class BQPhotoBrowserView: UIView {
    // MARK: - ***** Ivars *****
    public var delegate: BQPhotoBrowserViewDelegate?

    fileprivate var datas: [UIImage]
    fileprivate var pageControl: UIPageControl!
    private var collectionView: UICollectionView!
    private var index: Int = 0
    private var backView: UIView!
    private var animationView: UIImageView!

    // MARK: - ***** Class Method *****

    static func show(datas: [UIImage], current: Int = 0, delegate: BQPhotoBrowserViewDelegate? = nil) {
        let browser = BQPhotoBrowserView(frame: UIScreen.main.bounds, datas: datas, current: current)
        UIApplication.keyWindow?.addSubview(browser)
        browser.startAnimation()
    }

    // MARK: - ***** initialize Method *****

    private init(frame: CGRect, datas: [UIImage], current: Int = 0) {
        self.datas = datas
        super.init(frame: frame)
        index = current
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
        backView.backgroundColor = UIColor.black
        addSubview(backView)
        createCollection()
        createPageContrl()
        animationView = UIImageView(frame: CGRect.zero)
        addSubview(animationView)
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
    }

    private func startAnimation() {
        if let delegate = delegate, let fromRect = delegate.startAnimationFromFrame(currentIndex: index) {
            backView.alpha = 0
            collectionView.alpha = 0
            pageControl.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                self.configImgFrame(frame: fromRect)
                self.backView.alpha = 1
            }) { _ in
                self.animationView.alpha = 0
                self.collectionView.alpha = 1
                self.pageControl.alpha = 1
            }
        } else {
            animationView.alpha = 0
        }
    }

    fileprivate func removeSelf(row: Int) {
        index = row
        if let delegate = delegate, let toRect = delegate.removeAnimationToFrame(currentIndex: index) {
            configImgFrame(frame: toRect)
            animationView.alpha = 1
            collectionView.alpha = 0
            pageControl.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                self.backView.alpha = 0
                self.animationView.frame = toRect
            }) { _ in
                self.removeFromSuperview()
            }
        } else {
            self.removeFromSuperview()
        }
    }

    func configImgFrame(frame: CGRect) {
        let imgSize = frame.size
        let height = imgSize.height * (sizeW - 16) / imgSize.width
        let frame = CGRect(x: 8, y: (sizeH - height) * 0.5, width: sizeW - 16, height: height)
        animationView.image = datas[index]
        animationView.frame = frame
    }

    // MARK: - ***** LoadData Method *****

    // MARK: - ***** respond event Method *****

    // MARK: - ***** create Method *****

    func createCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = UIScreen.main.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.register(PhotoCollectionCell.classForCoder(), forCellWithReuseIdentifier: identifi)
        addSubview(collectionView)
    }

    func createPageContrl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: sizeW, height: 30))
        pageControl.center = CGPoint(x: sizeW * 0.5, y: sizeH - 70)
        pageControl.numberOfPages = datas.count
        pageControl.currentPage = index
        addSubview(pageControl)
    }
}

extension BQPhotoBrowserView: UICollectionViewDelegate, UICollectionViewDataSource, PhotoCellDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return datas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifi, for: indexPath) as! PhotoCollectionCell
        cell.delegate = self
        cell.row = indexPath.row
        cell.setImage(img: datas[indexPath.row])
        return cell
    }

    func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt _: IndexPath) {
        let photoCell = cell as! PhotoCollectionCell
        photoCell.photoView.zoomNormal()
    }

    func photoTapAction(row: Int) {
        removeSelf(row: row)
    }
}

extension BQPhotoBrowserView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int((scrollView.contentOffset.x + scrollView.sizeW * 0.5) / scrollView.sizeW)
    }
}

protocol PhotoCellDelegate: NSObjectProtocol {
    func photoTapAction(row: Int)
}

class PhotoCollectionCell: UICollectionViewCell {
    fileprivate var photoView: BQPhotoView!
    weak var delegate: PhotoCellDelegate?
    var row: Int = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        let photoView = BQPhotoView(frame: frame)
        contentView.addSubview(photoView)
        self.photoView = photoView
        self.photoView.tapAction { [weak self] _ in
            self?.delegate?.photoTapAction(row: (self?.row)!)
        }
    }

    func setImage(img: UIImage?) {
        if let image = img {
            photoView.zoomNormal()
            let imgSize = image.size
            let height = imgSize.height * photoView.sizeW / imgSize.width
            let frame = CGRect(x: 0, y: (photoView.sizeH - height) * 0.5, width: photoView.sizeW, height: height)
            photoView.imageView.frame = frame
            photoView.imageView.image = img
        } else {
            photoView.imageView.image = nil
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension BQPhotoBrowserViewDelegate {
    func startAnimationFromFrame(currentIndex: Int) -> CGRect? {
        return nil
    }
    
    func removeAnimationToFrame(currentIndex: Int) -> CGRect? {
        return nil
    }
}
