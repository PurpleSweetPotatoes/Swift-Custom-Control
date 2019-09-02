// *******************************************
//  File Name:      UIImage+BQExtension.swift       
//  Author:         MrBai
//  Created Date:   2019/8/15 3:17 PM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************
    

import UIKit

private let colorSpaceRef = CGColorSpaceCreateDeviceRGB()

extension UIImage {
    
    class func orginImg(name: String) -> UIImage? {
        return UIImage(named: name)?.withRenderingMode(.alwaysOriginal)
    }
    
    /// 图片质量压缩
    ///
    /// - Parameters:
    ///   - aimLength: 压缩大小(kb)
    ///   - accuracy: 压缩误差范围(kb)
    /// - Returns: 压缩后的图片数据
    func compress(aimLength: Int, accuracy: Int) -> Data {
        return self.compress(width: self.size.width, aimLength: aimLength, accuracy: accuracy)
    }
    
    /// 图片质量压缩
    ///
    /// - Parameters:
    ///   - width: 压缩后宽最大值
    ///   - aimLength: 压缩大小(kb)
    ///   - accuracy: 压缩误差范围(kb)
    /// - Returns: 压缩后的图片数据
    func compress(width:CGFloat, aimLength: Int, accuracy: Int) -> Data {
        
        let imgWidth = self.size.width
        let imgHeight = self.size.height
        var aimSize: CGSize
        if width >= imgWidth {
            aimSize = self.size;
        }else {
            aimSize = CGSize(width: width,height: width*imgHeight/imgWidth);
        }
        
        UIGraphicsBeginImageContext(aimSize);
        self.draw(in: CGRect(origin: CGPoint.zero, size: aimSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        let data = newImage.jpegData(compressionQuality: 1)!
        
        var dataLen = data.count
        let aim_max = aimLength * 1024 + accuracy * 1024
        let aim_min = aimLength * 1024 - accuracy * 1024
        
        if (dataLen <= aim_max) {
            return data;
        } else {
            var maxQuality: CGFloat = 1.0
            var minQuality: CGFloat = 0.0
            var flag = 0
            
            while true {
                let midQuality = (minQuality + maxQuality) * 0.5
                
                if flag > 6 {
                    return newImage.jpegData(compressionQuality: minQuality)!
                }
                
                flag += 1
                
                let imageData = newImage.jpegData(compressionQuality: minQuality)!
                dataLen = imageData.count
                
                if dataLen > aim_max{
                    maxQuality = midQuality
                    continue
                } else if dataLen < aim_min {
                    minQuality = midQuality;
                    continue;
                } else {
                    return imageData;
                }
            }
        }
    }
    
    func fillColor(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context?.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context?.fill(rect)
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImg ?? self
    }
    
    func reSizeImage(reSize:CGSize, round: Bool = false)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: reSize.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        if round {
            context?.addEllipse(in: CGRect(origin: CGPoint.zero, size: reSize))
            context?.clip()
        }
        context?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage ?? self;
    }
    
    static var appIcon: UIImage? {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String:Any],
            let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String:Any],
            let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last else { return nil }
        return UIImage(named: lastIcon)
    }
    
    /// Process Image use a bitmap context
    ///
    /// - Returns: success  => an image containing a snapshot of the bitmap context `context'
    ///            fail     => self
    func decompressedImg() -> UIImage {
        if self.images != nil || self.cgImage == nil {
            return self
        }
        
        let imgRef = self.cgImage!
        
        let hasAlpha = !(imgRef.alphaInfo == .none || imgRef.alphaInfo == .noneSkipFirst || imgRef.alphaInfo == .noneSkipLast)
        let bitmapInfo = CGBitmapInfo.byteOrder32Little
        let bitRaw = bitmapInfo.rawValue | (hasAlpha ? CGImageAlphaInfo.premultipliedFirst.rawValue : CGImageAlphaInfo.noneSkipFirst.rawValue)
        // create bitmap graphics contexts without alpha info
        let bitContext = CGContext(data: nil, width: imgRef.width, height: imgRef.height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpaceRef, bitmapInfo: bitRaw)
        if bitContext == nil {
            return self
        }
        
        bitContext!.draw(imgRef, in: CGRect(x: 0, y: 0, width: imgRef.width, height: imgRef.height))
        let imgRefWithOutAlpha = bitContext!.makeImage()!
        let backImg = UIImage(cgImage: imgRefWithOutAlpha, scale: self.scale, orientation: self.imageOrientation)
        
        return backImg
    }
}
