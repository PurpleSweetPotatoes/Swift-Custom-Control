// *******************************************
//  File Name:      UIImageView+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/8/15 4:20 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

private let IOImageQueue = DispatchQueue(label: "IOImageQueue", qos: DispatchQoS.default, attributes: DispatchQueue.Attributes.concurrent)

public extension UIImageView {
    func canShow() {
        addTapGes { [weak self] _ in
            if let image = self?.image {
                BQShowImageView.show(image, origiFrame: (self?.superview!.convert((self?.frame)!, to: UIApplication.keyWindow?.rootViewController?.view))!)
            }
        }
    }

    func displayImage(imageFileName: String, bundle: Bundle = Bundle.main) {
        if let path = bundle.path(forResource: imageFileName, ofType: nil) {
            if let image = UIImage(contentsOfFile: path) {
                displayImage(image: image)
            }
        }
    }

    func displayImage(image: UIImage) {
        IOImageQueue.async {
            let leftImage = image.decompressedImage()
            DispatchQueue.main.async {
                self.image = leftImage
            }
        }
    }

    func setGifImage(name: String?, bundle: Bundle = Bundle.main) {
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

        var animatedImage: UIImage?

        if count <= 1 {
            animatedImage = UIImage(data: data)
        } else {
            var cgImages: [UIImage] = []
            var duration: TimeInterval = 0

            for i in 0 ... count {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    duration += type(of: self).frameDuration(index: i, source: source)
                    cgImages.append(UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up))
                }
            }

            if duration == 0 {
                duration = (1.0 / 10.0) * Double(count)
            }

            animatedImage = UIImage.animatedImage(with: cgImages, duration: duration)
        }

        image = animatedImage
    }

    static func frameDuration(index: Int, source: CGImageSource) -> Double {
        var frameDuration = 0.1
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

    static func show(_ image: UIImage, origiFrame: CGRect) {
        let showView = BQShowImageView(frame: UIScreen.main.bounds)
        showView.initUI()
        showView.imageView.image = image
        showView.origiFrame = origiFrame
        showView.addTapGes { [weak showView] _ in
            showView?.removeSelf()
        }
        UIApplication.keyWindow?.rootViewController?.view.addSubview(showView)
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
