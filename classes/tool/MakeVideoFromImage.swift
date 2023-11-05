//
//  MakeVideoFromImage.swift
//  Langwan_VideoClipEditor
//
//  Created by langwan on 2020/2/22.
//  Copyright © 2020 langwan. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

public class MakeVideoFromImage {
    public init() {}
    
    public func make(image:UIImage, handler: @escaping (_ url:URL) -> Void) {
        let url = self.genUrl()
        do {
            let assetWriter = try AVAssetWriter(outputURL: url, fileType: .mov)
            
            let videoSettings:[String:Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: image.size.width,
                AVVideoHeightKey: image.size.height
            ]
            
            let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            
            let attributes : [String: AnyObject] = [
                kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA),
                kCVPixelBufferWidthKey as String: NSNumber(value: Int32(image.size.width)),
                kCVPixelBufferHeightKey as String: NSNumber(value: Int32(image.size.height))
            ]
            
            let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: attributes)
            
            assetWriter.add(videoWriterInput)
            assetWriter.startWriting()
            assetWriter.startSession(atSourceTime: CMTime.zero)
            
            autoreleasepool {
                while adaptor.assetWriterInput.isReadyForMoreMediaData == false {
                    Thread.sleep(forTimeInterval: 0.01)
                }
                
                let buffer = self.pixelBufferFromImage(image: image)
                adaptor.append(buffer, withPresentationTime: CMTime.zero)
            }
            
            videoWriterInput.markAsFinished()
            
            assetWriter.finishWriting(completionHandler: {
                if assetWriter.status == AVAssetWriter.Status.completed {
                    handler(url)
                }
            })
            
        } catch {
            BQLogger.error(error.localizedDescription)
        }
    }
    
    public func genUrl() -> URL {
        let directory = NSTemporaryDirectory()
        let fileName = Date().toString(format: "yyyyMMdd_HHmmss_") + NSUUID().uuidString + ".mov"
        return NSURL.fileURL(withPathComponents: [directory, fileName])!
    }
    
    public func pixelBufferFromImage(image: UIImage) -> CVPixelBuffer {
        
        let ciImage = CIImage(image: image)
        //let cgimage = convertCIImageToCGImage(inputImage: ciimage!)
        let tmpcontext = CIContext(options: nil)
        let cgImage =  tmpcontext.createCGImage(ciImage!, from: ciImage!.extent)

        let cfnumPointer = UnsafeMutablePointer<UnsafeRawPointer>.allocate(capacity: 1)
        let cfnum = CFNumberCreate(kCFAllocatorDefault, .intType, cfnumPointer)
        let keys: [CFString] = [kCVPixelBufferCGImageCompatibilityKey, kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferBytesPerRowAlignmentKey]
        let values: [CFTypeRef] = [kCFBooleanTrue, kCFBooleanTrue, cfnum!]
        let keysPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        let valuesPointer =  UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        keysPointer.initialize(to: keys.withUnsafeBytes { $0.baseAddress })
        valuesPointer.initialize(to: values.withUnsafeBytes { $0.baseAddress })

        let options = CFDictionaryCreate(kCFAllocatorDefault, keysPointer, valuesPointer, keys.count, nil, nil)
        
        let width = cgImage!.width
        let height = cgImage!.height
        
        var pxBuffer: CVPixelBuffer?
        // if pxBuffer = nil, you will get status = -6661
        CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                         kCVPixelFormatType_32BGRA, options, &pxBuffer)
        CVPixelBufferLockBaseAddress(pxBuffer!, CVPixelBufferLockFlags(rawValue: 0));
        
        let bufferAddress = CVPixelBufferGetBaseAddress(pxBuffer!);
        
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pxBuffer!)
        let context = CGContext(data: bufferAddress,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesPerRow,
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue);
        context?.concatenate(CGAffineTransform(rotationAngle: 0))
        context?.concatenate(__CGAffineTransformMake( 1, 0, 0, -1, 0, CGFloat(height) )) //Flip Vertical
        UIGraphicsPushContext(context!)
        
        image.draw( in: CGRect(x:0, y:0, width:CGFloat(width), height:CGFloat(height)))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pxBuffer!, CVPixelBufferLockFlags(rawValue: 0));
        return pxBuffer!;
        
    }
}
