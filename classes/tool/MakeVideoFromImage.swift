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

class MakeVideoFromImage {
    
    func make(image:UIImage, handler: @escaping (_ url:URL) -> Void) {
        let url = self.genUrl()
        do {
            let assetWriter = try AVAssetWriter(outputURL: url, fileType: .mov)
            
            let videoSettings:[String:Any] = [
                AVVideoCodecKey: AVVideoCodecH264,
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
            print(error.localizedDescription)
        }
    }
    
    func genUrl() -> URL {
        let directory = NSTemporaryDirectory()
        let fileName = NSUUID().uuidString + ".mov"
        return NSURL.fileURL(withPathComponents: [directory, fileName])!
    }
    
    func pixelBufferFromImage(image: UIImage) -> CVPixelBuffer {
        
        let ciimage = CIImage(image: image)
        //let cgimage = convertCIImageToCGImage(inputImage: ciimage!)
        let tmpcontext = CIContext(options: nil)
        let cgimage =  tmpcontext.createCGImage(ciimage!, from: ciimage!.extent)
        
        let cfnumPointer = UnsafeMutablePointer<UnsafeRawPointer>.allocate(capacity: 1)
        let cfnum = CFNumberCreate(kCFAllocatorDefault, .intType, cfnumPointer)
        let keys: [CFString] = [kCVPixelBufferCGImageCompatibilityKey, kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferBytesPerRowAlignmentKey]
        let values: [CFTypeRef] = [kCFBooleanTrue, kCFBooleanTrue, cfnum!]
        let keysPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        let valuesPointer =  UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        keysPointer.initialize(to: keys)
        valuesPointer.initialize(to: values)
        
        let options = CFDictionaryCreate(kCFAllocatorDefault, keysPointer, valuesPointer, keys.count, nil, nil)
        
        let width = cgimage!.width
        let height = cgimage!.height
        
        var pxbuffer: CVPixelBuffer?
        // if pxbuffer = nil, you will get status = -6661
        CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                         kCVPixelFormatType_32BGRA, options, &pxbuffer)
        CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
        
        let bufferAddress = CVPixelBufferGetBaseAddress(pxbuffer!);
        
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        let bytesperrow = CVPixelBufferGetBytesPerRow(pxbuffer!)
        let context = CGContext(data: bufferAddress,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesperrow,
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue);
        context?.concatenate(CGAffineTransform(rotationAngle: 0))
        context?.concatenate(__CGAffineTransformMake( 1, 0, 0, -1, 0, CGFloat(height) )) //Flip Vertical
        //        context?.concatenate(__CGAffineTransformMake( -1.0, 0.0, 0.0, 1.0, CGFloat(width), 0.0)) //Flip Horizontal
        
        UIGraphicsPushContext(context!)
        
        image.draw( in: CGRect(x:0, y:0, width:CGFloat(width), height:CGFloat(height)))
        UIGraphicsPopContext()
        //context?.draw(cgimage!, in: CGRect(x:0, y:0, width:CGFloat(width), height:CGFloat(height)));
        CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
        return pxbuffer!;
        
    }
}
