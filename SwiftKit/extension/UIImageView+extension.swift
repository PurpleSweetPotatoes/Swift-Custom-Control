//
//  UIImageView+extension.swift
//  HJLBusiness
//
//  Created by MrBai on 2017/5/17.
//  Copyright © 2017年 baiqiang. All rights reserved.
//


//需导入Kingfisher三方库
import Foundation
//import Kingfisher
import UIKit

extension UIImageView {
    
    func setImage(urlStr: String?) {
//        if let ulrString = urlStr {
//            self.kf.setImage(with: URL(string: urlStr!), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
//        }
    }
    
    
    func canshow() {
        self.addTapGes {[weak self] (view) in
            if let image = self?.image {
                BQShowImageView.show(img: image, origiFrame: (self?.superview!.convert((self?.frame)!, to: UIApplication.shared.keyWindow?.rootViewController?.view))!)
            }
        }
    }
    
    func setGifImg(name: String?, bundle:Bundle = Bundle.main) {
        
        guard let gifName = name else {
            return
        }
        
        var data: Data = Data()
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
        }else {
            var imgs: [UIImage] = []
            var duration: TimeInterval = 0
            
            for i in (0...count) {
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
        
        self.image = animatedImg
    }
    
    class func frameDuration(index:Int, source:CGImageSource) -> Double {
        var frameDuration: Double = 0.1
        let frameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)! as! Dictionary<String, AnyObject>
        let gifProperties = frameProperties[kCGImagePropertyGIFDictionary as String] as! Dictionary<String, AnyObject>
        let delayTimeUnclampedProp = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber
        
        if let delayTime = delayTimeUnclampedProp {
            frameDuration = Double(delayTime.floatValue)
        }else {
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



private var startCenter: CGPoint = CGPoint(x:0, y:0)
private var startScale: CGFloat = 1

class BQShowImageView: UIView {
    let imageView: UIImageView = UIImageView()
    let backView: UIView = UIView(frame: UIScreen.main.bounds)
    var origiFrame: CGRect! {
        didSet {
            self.imageView.frame = self.origiFrame
        }
    }
    class func show(img:UIImage, origiFrame:CGRect) {
        let showView = BQShowImageView(frame: UIScreen.main.bounds)
        showView.initUI()
        showView.imageView.image = img
        showView.origiFrame = origiFrame
        showView.addTapGes {[weak showView] (view) in
            showView?.removeSelf()
        }
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(showView)
        showView.startShow()
    }
    private func initUI() {
        self.backView.backgroundColor = UIColor(white: 0.2, alpha: 0.7)
        self.addSubview(self.backView)
        self.imageView.isUserInteractionEnabled = true
        self.backView.addSubview(self.imageView)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.gestureAction(gesture:)))
        self.imageView.addGestureRecognizer(pan)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.gestureAction(gesture:)))
        self.imageView.addGestureRecognizer(pinch)
    }
    @objc private func gestureAction(gesture:UIGestureRecognizer) {
        if gesture is UIPanGestureRecognizer {
            switch gesture.state {
            case .began:
                startCenter = self.imageView.center
            case .changed:
                let pan = gesture as! UIPanGestureRecognizer
                let translation = pan.translation(in: self)
                self.imageView.center = CGPoint(x: startCenter.x + translation.x, y: startCenter.y + translation.y)
            case .ended:
                startCenter = CGPoint(x:0, y:0)
            default:
                break
            }
        }else if gesture is UIPinchGestureRecognizer {
            let pinch = gesture as! UIPinchGestureRecognizer
            switch gesture.state {
            case .began:
                startScale = pinch.scale
            case .changed:
                let scale = (pinch.scale - startScale) + 1
                self.imageView.transform = self.imageView.transform.scaledBy(x: scale, y: scale)
                startScale = pinch.scale
            case .ended:
                startScale = 1
            default:
                break
            }
        }
    }
    private func startShow() {
        self.backView.alpha = 0;
        let toWidth = self.sizeW - 10;
        let toHeight = self.imageView.sizeH * toWidth / self.imageView.sizeW;
        UIView.animate(withDuration: 0.25) {
            self.backView.alpha = 1;
            self.imageView.bounds = CGRect(x:0, y:0, width:toWidth, height:toHeight);
            self.imageView.center = self.center;
        }
    }
    private func removeSelf() {
        UIView.animate(withDuration: 0.25, animations: {
            self.imageView.frame = self.origiFrame!
        }) { (finish) in
            self.removeFromSuperview()
        }
    }
}
