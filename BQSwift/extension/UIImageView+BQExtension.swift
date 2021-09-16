// *******************************************
//  File Name:      UIImageView+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/8/15 4:20 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

private let ioImgQueue = DispatchQueue(label: "ioImgQueue", qos: DispatchQoS.default, attributes: DispatchQueue.Attributes.concurrent)

extension UIImageView {
    func canshow() {
        addTapGes { [weak self] _ in
            if let image = self?.image {
                BQShowImageView.show(img: image, origiFrame: (self?.superview!.convert((self?.frame)!, to: UIApplication.shared.keyWindow?.rootViewController?.view))!)
            }
        }
    }

    func displayImg(imgFileName: String, bundle: Bundle = Bundle.main) {
        if let path = bundle.path(forResource: imgFileName, ofType: nil) {
            if let img = UIImage(contentsOfFile: path) {
                displayImg(img: img)
            }
        }
    }

    func displayImg(img: UIImage) {
        ioImgQueue.async {
            let leftImg = img.decompressedImg()
            DispatchQueue.main.async {
                self.image = leftImg
            }
        }
    }

    func setGifImg(name: String?, bundle: Bundle = Bundle.main) {
        guard let gifName = name else {
            return
        }

        var data = Data()
        let originPath = bundle.path(forResource: gifName, ofType: "gif")

        if UIScreen.main.scale > 1.0 {
            let retinaPath = bundle.path(forResource: gifName.appendingFormat("@2x"), ofType: "gif")
            data = NSData(contentsOfFile: retinaPath!)! as Data
        }

        if data.isEmpty {
            data = NSData(contentsOfFile: originPath!)! as Data
        }

        if data.isEmpty { return }

        let source: CGImageSource = CGImageSourceCreateWithData(data as CFData, nil)!
        let count: size_t = CGImageSourceGetCount(source)

        var animatedImg: UIImage?

        if count <= 1 {
            animatedImg = UIImage(data: data)
        } else {
            var imgs: [UIImage] = []
            var duration: TimeInterval = 0

            for i in 0 ... count {
                let image: CGImage? = CGImageSourceCreateImageAtIndex(source, i, nil)
                if let img = image {
                    duration += type(of: self).frameDuration(index: i, source: source)
                    imgs.append(UIImage(cgImage: img, scale: UIScreen.main.scale, orientation: .up))
                }
            }

            if duration == 0 {
                duration = (1.0 / 10.0) * Double(count)
            }

            animatedImg = UIImage.animatedImage(with: imgs, duration: duration)
        }

        image = animatedImg
    }

    class func frameDuration(index: Int, source: CGImageSource) -> Double {
        var frameDuration: Double = 0.1
        let frameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)! as! [String: AnyObject]
        let gifProperties = frameProperties[kCGImagePropertyGIFDictionary as String] as! [String: AnyObject]
        let delayTimeUnclampedProp = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber

        if let delayTime = delayTimeUnclampedProp {
            frameDuration = Double(delayTime.floatValue)
        } else {
            let delayTimeProp = gifProperties[kCGImagePropertyGIFDelayTime as String] as? NSNumber
            if let delayTime = delayTimeProp {
                frameDuration = Double(delayTime.floatValue)
            }
        }

        if frameDuration < 0.011 {
            frameDuration = 0.1
        }

        return frameDuration
    }
}

private var startCenter = CGPoint(x: 0, y: 0)
private var startScale: CGFloat = 1

class BQShowImageView: UIView {
    let imageView = UIImageView()
    let backView = UIView(frame: UIScreen.main.bounds)
    var origiFrame: CGRect! {
        didSet {
            imageView.frame = origiFrame
        }
    }

    class func show(img: UIImage, origiFrame: CGRect) {
        let showView = BQShowImageView(frame: UIScreen.main.bounds)
        showView.initUI()
        showView.imageView.image = img
        showView.origiFrame = origiFrame
        showView.addTapGes { [weak showView] _ in
            showView?.removeSelf()
        }
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(showView)
        showView.startShow()
    }

    private func initUI() {
        backView.backgroundColor = UIColor(white: 0.2, alpha: 0.7)
        addSubview(backView)
        imageView.isUserInteractionEnabled = true
        backView.addSubview(imageView)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(gestureAction(gesture:)))
        imageView.addGestureRecognizer(pan)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(gestureAction(gesture:)))
        imageView.addGestureRecognizer(pinch)
    }

    @objc private func gestureAction(gesture: UIGestureRecognizer) {
        if gesture is UIPanGestureRecognizer {
            switch gesture.state {
            case .began:
                startCenter = imageView.center
            case .changed:
                let pan = gesture as! UIPanGestureRecognizer
                let translation = pan.translation(in: self)
                imageView.center = CGPoint(x: startCenter.x + translation.x, y: startCenter.y + translation.y)
            case .ended:
                startCenter = CGPoint(x: 0, y: 0)
            default:
                break
            }
        } else if gesture is UIPinchGestureRecognizer {
            let pinch = gesture as! UIPinchGestureRecognizer
            switch gesture.state {
            case .began:
                startScale = pinch.scale
            case .changed:
                let scale = (pinch.scale - startScale) + 1
                imageView.transform = imageView.transform.scaledBy(x: scale, y: scale)
                startScale = pinch.scale
            case .ended:
                startScale = 1
            default:
                break
            }
        }
    }

    private func startShow() {
        backView.alpha = 0
        let toWidth = sizeW - 10
        let toHeight = imageView.sizeH * toWidth / imageView.sizeW
        UIView.animate(withDuration: 0.25) {
            self.backView.alpha = 1
            self.imageView.bounds = CGRect(x: 0, y: 0, width: toWidth, height: toHeight)
            self.imageView.center = self.center
        }
    }

    private func removeSelf() {
        UIView.animate(withDuration: 0.25, animations: {
            self.imageView.frame = self.origiFrame!
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
