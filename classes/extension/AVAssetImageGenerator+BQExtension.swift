// *******************************************
//  File Name:      AVAssetImageGenerator+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2021/6/23 5:46 PM
//
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import AVFoundation
import UIKit

extension AVAssetImageGenerator {
    func frameImage(_ atTime: CMTimeValue) -> UIImage? {
        appliesPreferredTrackTransform = true
        requestedTimeToleranceBefore = CMTime.zero
        requestedTimeToleranceAfter = CMTime.zero
        let time = CMTime(value: atTime, timescale: 1)
        if let cgimg = try? copyCGImage(at: time, actualTime: nil) {
            return UIImage(cgImage: cgimg)
        } else {
            return nil
        }
    }
}
