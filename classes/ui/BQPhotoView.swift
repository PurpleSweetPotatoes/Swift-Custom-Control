// *******************************************
//  File Name:      BQPhotoView.swift
//  Author:         MrBai
//  Created Date:   2019/8/20 2:39 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

class BQPhotoView: UIView {
    // MARK: - ***** Ivars *****

    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var singleTapAction: ((UITapGestureRecognizer) -> Void)?
    fileprivate var scrollView: UIScrollView!
    private var backView: UIView!
    fileprivate var origiFrame: CGRect!

    static func show(imgView: UIImageView) {
        guard let image = imgView.image, let supView = imgView.superview else {
            return
        }
        let showView = BQPhotoView(frame: UIScreen.main.bounds)
        showView.imageView.image = image
        showView.origiFrame = supView.convert(imgView.frame, to: UIApplication.keyWindow?.rootViewController?.view)
        showView.tapAction { _ in
            showView.removeSelf()
        }
        UIApplication.keyWindow?.rootViewController?.view.addSubview(showView)
        showView.startAnimation()
    }

    static func show(img: UIImage) {
        let showView = BQPhotoView(frame: UIScreen.main.bounds)
        showView.imageView.image = img
        let imgSize = img.size
        let height = imgSize.height * showView.sizeW / imgSize.width
        let frame = CGRect(x: 0, y: (showView.sizeH - height) * 0.5, width: showView.sizeW, height: height)
        showView.imageView.frame = frame
        UIApplication.keyWindow?.rootViewController?.view.addSubview(showView)
    }

    // MARK: - ***** initialize Method *****

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        initGesture()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ***** public Method *****

    func tapAction(handle: @escaping (UITapGestureRecognizer) -> Void) {
        singleTapAction = handle
    }

    func zoomNormal() {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        }
    }

    // MARK: - ***** private Method *****

    private func initGesture() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(ges:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(ges:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        // 允许优先执行doubleTap, 在doubleTap执行失败的时候执行singleTap, 如果没有设置这个, 那么将只会执行singleTap 不会执行doubleTap
        singleTap.require(toFail: doubleTap)
        addGestureRecognizer(singleTap)
        addGestureRecognizer(doubleTap)
    }

    private func initUI() {
        backView = UIView(frame: bounds)
        backView.backgroundColor = UIColor.black
        addSubview(backView)
        addScrollView()
    }

    private func startAnimation() {
        imageView.frame = origiFrame
        backView.alpha = 0
        let imgSize = imageView.image!.size
        let height = imgSize.height * sizeW / imgSize.width
        let frame = CGRect(x: 0, y: (sizeH - height) * 0.5, width: sizeW, height: height)
        UIView.animate(withDuration: 0.25, animations: {
            self.imageView.frame = frame
            self.backView.alpha = 1
        })
    }

    private func removeSelf() {
        UIView.animate(withDuration: 0.25, animations: {
            self.backView.alpha = 0
            self.imageView.frame = self.origiFrame!
        }) { _ in
            self.removeFromSuperview()
        }
    }

    // MARK: - ***** LoadData Method *****

    // MARK: - ***** respond event Method *****

    // 单击手势, 给外界处理
    @objc private func handleSingleTap(ges: UITapGestureRecognizer) {
        // 首先缩放到最小倍数, 以便于执行退出动画时frame可以同步改变
        if scrollView.zoomScale != scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        }
        singleTapAction?(ges)
    }

    @objc private func handleDoubleTap(ges: UITapGestureRecognizer) {
        if imageView.image == nil {
            return
        }
        if scrollView.zoomScale <= scrollView.minimumZoomScale {
            let location = ges.location(in: imageView)
            let width = imageView.sizeW / scrollView.maximumZoomScale
            let height = imageView.sizeH / scrollView.maximumZoomScale
            let rect = CGRect(x: location.x - width * 0.5, y: location.y - height * 0.5, width: width, height: height)
            scrollView.zoom(to: rect, animated: true)
            print(scrollView.contentOffset)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }

    // MARK: - ***** create Method *****

    private func addScrollView() {
        let scrollView = UIScrollView(frame: bounds)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = true
        scrollView.maximumZoomScale = 2.0
        scrollView.minimumZoomScale = 1.0
        scrollView.delegate = self
        imageView.frame = scrollView.bounds
        scrollView.addSubview(imageView)
        addSubview(scrollView)
        self.scrollView = scrollView
    }
}

// MARK: - ***** scrollviewDelegate *****

extension BQPhotoView: UIScrollViewDelegate {
    func viewForZooming(in _: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_: UIScrollView) {
        // 居中显示图片
        setImageViewToTheCenter()
    }

    // 居中显示图片
    func setImageViewToTheCenter() {
        let offsetX = (scrollView.sizeW > scrollView.contentSize.width) ? (scrollView.sizeW - scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY = (scrollView.sizeH > scrollView.contentSize.height) ? (scrollView.sizeH - scrollView.contentSize.height) * 0.5 : 0.0

        imageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
}
