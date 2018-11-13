//
//  UIImage+extension.swift
//  swift4.2Demo
//
//  Created by baiqiang on 2018/10/6.
//  Copyright © 2018年 baiqiang. All rights reserved.
//

import UIKit

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
}
