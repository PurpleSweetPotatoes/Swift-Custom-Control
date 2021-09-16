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

enum ArrowDirection {
    case top
    case left
    case bottom
    case right
}

extension UIImage {
    class func orginImg(name: String) -> UIImage? {
        return UIImage(named: name)?.withRenderingMode(.alwaysOriginal)
    }

    static var appIcon: UIImage? {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
              let lastIcon = iconFiles.last else { return nil }
        return UIImage(named: lastIcon)
    }

    // MARK: - 压缩相关

    /// 图片质量压缩
    ///
    /// - Parameters:
    ///   - aimLength: 压缩大小(kb)
    ///   - accuracy: 压缩误差范围(kb)
    /// - Returns: 压缩后的图片数据
    func compress(aimLength: Int, accuracy: Int) -> Data {
        return compress(width: size.width, aimLength: aimLength, accuracy: accuracy)
    }

    /// 图片质量压缩
    ///
    /// - Parameters:
    ///   - width: 压缩后宽最大值
    ///   - aimLength: 压缩大小(kb)
    ///   - accuracy: 压缩误差范围(kb)
    /// - Returns: 压缩后的图片数据
    func compress(width: CGFloat, aimLength: Int, accuracy: Int) -> Data {
        let imgWidth = size.width
        let imgHeight = size.height
        var aimSize: CGSize
        if width >= imgWidth {
            aimSize = size
        } else {
            aimSize = CGSize(width: width, height: width * imgHeight / imgWidth)
        }

        UIGraphicsBeginImageContext(aimSize)
        draw(in: CGRect(origin: CGPoint.zero, size: aimSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        let data = newImage.jpegData(compressionQuality: 1)!

        var dataLen = data.count
        let aim_max = aimLength * 1024 + accuracy * 1024
        let aim_min = aimLength * 1024 - accuracy * 1024

        if dataLen <= aim_max {
            return data
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

                if dataLen > aim_max {
                    maxQuality = midQuality
                    continue
                } else if dataLen < aim_min {
                    minQuality = midQuality
                    continue
                } else {
                    return imageData
                }
            }
        }
    }

    // MARK: - 填充

    func fillColor(_ color: UIColor, _ model: CGBlendMode = .destinationIn) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()

        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        color.setFill()
        context?.fill(bounds)

        draw(in: bounds, blendMode: model, alpha: 1.0)

        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImg ?? self
    }

    func addImg(img: UIImage, alpha: CGFloat = 1.0, rect: CGRect? = nil) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        img.draw(in: rect ?? CGRect(origin: CGPoint.zero, size: img.size), blendMode: .normal, alpha: alpha)
        let opImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return opImg
    }

    // MARK: - 处理

    func reSizeImage(reSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(reSize, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: reSize.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        context?.draw(cgImage!, in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return reSizeImage ?? self
    }

    func round() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.addEllipse(in: CGRect(origin: CGPoint.zero, size: size))
        context?.clip()
        context?.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let reSizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return reSizeImage ?? self
    }

    func clipImage(_ inRect: CGRect) -> UIImage? {
        if (inRect.maxX > size.width) || (inRect.maxY > size.height) {
            return nil
        }
        if let imgRef = cgImage?.cropping(to: inRect) {
            return UIImage(cgImage: imgRef, scale: scale, orientation: imageOrientation)
        }
        return nil
    }

    func blurred(_ radius: CGFloat) -> UIImage {
        let ciContext = CIContext(options: nil)
        guard let cgImage = cgImage else { return self }
        let inputImage = CIImage(cgImage: cgImage)
        guard let ciFilter = CIFilter(name: "CIGaussianBlur") else { return self }
        ciFilter.setValue(inputImage, forKey: kCIInputImageKey)
        ciFilter.setValue(radius, forKey: "inputRadius")
        guard let resultImage = ciFilter.value(forKey: kCIOutputImageKey) as? CIImage else { return self }
        guard let cgImage2 = ciContext.createCGImage(resultImage, from: inputImage.extent) else { return self }
        return UIImage(cgImage: cgImage2)
    }

    /// Process Image use a bitmap context
    ///
    /// - Returns: success  => an image containing a snapshot of the bitmap context `context'
    ///            fail     => self
    func decompressedImg() -> UIImage {
        if images != nil || cgImage == nil {
            return self
        }

        let imgRef = cgImage!

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
        let backImg = UIImage(cgImage: imgRefWithOutAlpha, scale: scale, orientation: imageOrientation)

        return backImg
    }

    // MARK: - 二维码

    class func qrcode(content: String, size: CGFloat? = nil) -> UIImage? {
        guard let ciImg = createCIImage(content) else {
            return nil
        }

        if let imgSize = size {
            let rect = ciImg.extent
            let scale = min(imgSize / rect.width, imgSize / rect.height)
            let context = CIContext(options: nil)
            if let bitImg = context.createCGImage(ciImg, from: rect) {
                let bitmapInfo = CGBitmapInfo.byteOrder32Little
                let bitRaw = bitmapInfo.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue
                let bitContext = CGContext(data: nil, width: Int(scale * rect.width), height: Int(scale * rect.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpaceRef, bitmapInfo: bitRaw)
                bitContext?.interpolationQuality = .none
                bitContext?.scaleBy(x: scale, y: scale)
                bitContext?.draw(bitImg, in: rect)
                if let cgimg = bitContext?.makeImage() {
                    if let prodata = cgimg.dataProvider {
                        let data = prodata.data!
                        BQLogger.log("\(data)")
                    }
                    return UIImage(cgImage: cgimg)
                }
            }
        }
        return UIImage(ciImage: ciImg)
    }

    /// 生成箭头图标
    /// - Parameters:
    ///   - size: 大小
    ///   - color: 颜色
    ///   - lineWidth: 线宽
    ///   - direction: 方向
    class func arrowImg(size: CGSize, color: UIColor, lineWidth: CGFloat, direction: ArrowDirection) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()

        var sp, cp, ep: CGPoint
        let sX = lineWidth * 0.5
        let eX = size.width - sX
        let sY = sX
        let eY = size.height - sX
        switch direction {
        case .top:
            sp = CGPoint(x: sX, y: eY - sX)
            cp = CGPoint(x: size.width * 0.5, y: sX)
            ep = CGPoint(x: eX, y: eY)
        case .left:
            sp = CGPoint(x: eX, y: sY)
            cp = CGPoint(x: sX, y: size.height * 0.5)
            ep = CGPoint(x: eX, y: eY - sX)
        case .bottom:
            sp = CGPoint(x: sX, y: sY)
            cp = CGPoint(x: size.width * 0.5, y: eY)
            ep = CGPoint(x: eX, y: sX)
        case .right:
            sp = CGPoint(x: sX, y: sY)
            cp = CGPoint(x: eX, y: size.height * 0.5)
            ep = CGPoint(x: sX, y: eY)
        }

        context?.move(to: sp)
        context?.addLine(to: cp)
        context?.addLine(to: ep)

        context?.setLineJoin(.round)
        context?.setLineCap(.round)
        context?.setLineWidth(lineWidth)
        context?.setStrokeColor(color.cgColor)
        context?.strokePath()

        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return img ?? UIImage()
    }

    // MARK: - 私有

    private class func createCIImage(_ content: String) -> CIImage? {
        let filder = CIFilter(name: "CIQRCodeGenerator")
        filder?.setDefaults()
        let data = content.data(using: .utf8)
        filder?.setValue(data, forKey: "inputMessage")
        filder?.setValue("H", forKey: "inputCorrectionLevel")
        return filder?.outputImage
    }
}
