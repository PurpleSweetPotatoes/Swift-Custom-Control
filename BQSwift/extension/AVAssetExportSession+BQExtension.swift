// *******************************************
//  File Name:      AVAssetExportSession+BQExtension.swift       
//  Author:         MrBai
//  Created Date:   2021/6/23 11:26 AM
//    
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import AVFoundation
import Foundation

typealias ExportBlock = (_ exportUrl: String?, _ errDesc: String?) -> Void

enum BQFileType: String {
    case mp4 = "mp4"
    case mov = "mov"
    case m4a = "m4a"
    case caf = "caf"
    
    func avFileType() -> AVFileType {
        switch self {
        case .mp4:
            return AVFileType.mp4
        case .mov:
            return AVFileType.mov
        case .m4a:
            return AVFileType.m4a
        case .caf:
            return AVFileType.caf
        }
    }
}

/// 合并素材对象
final class BQAssetTrack: NSObject {
    
    /// 素材资源
    private(set) public var track: AVAssetTrack?
    
    /// 素材使用区间
    private(set) public var insertRange: CMTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTime.zero)
    
    /// 素材插入时间点
    private(set) public var atTime: CMTime = CMTime.zero
    
    convenience init(_ inTrack: AVAssetTrack) {
        self.init()
        track = inTrack
        insertRange = CMTimeRangeMake(start: CMTime.zero, duration: inTrack.asset!.duration)
        atTime = CMTime.zero
    }
    
    /// 设置素材插入区间
    /// - Parameters:
    ///   - start: 起点
    ///   - duration: 时长
    public func setTrackRange(start: Int64, duration: Int64) {
        assert((Int64(track!.asset!.duration.seconds) - start) >= duration, "取样区间不在素材区间范围内")
        insertRange = CMTimeRangeMake(start: CMTimeMake(value: start, timescale: 1), duration: CMTimeMake(value: duration, timescale: 1))
    }
    
    /// 设置素材插入时间点
    public func setInsertTime(time: Int64) {
        atTime = CMTimeMake(value: time, timescale: 1)
    }
    
}


extension AVAssetExportSession {
    
    /// 生成素材合成样本,可用于试看
    /// - Parameter trackList: 素材列表
    static func composition(trackList: [BQAssetTrack]) -> AVMutableComposition? {
        if trackList.count == 0 {
            return nil
        }

        let compostion = AVMutableComposition()
        for bqTrack in trackList {
            if let track = bqTrack.track {
                if let comTrack = compostion.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: kCMPersistentTrackID_Invalid) {
                    do {
                        try comTrack.insertTimeRange(bqTrack.insertRange, of: track, at: bqTrack.atTime)
                    } catch {
                        print("插入素材失败")
                    }
                    
                }
            }
        }
        return compostion
    }
    
    /// 压缩导出音视频文件
    /// - Parameters:
    ///   - type: 导出文件类型
    ///   - trackList: 素材列表
    ///   - presetName: 导出预设样式
    ///   - handle: 回调
    static func compositionFile(type: BQFileType, trackList: [BQAssetTrack], presetName: String, handle: @escaping ExportBlock) -> AVAssetExportSession? {
        if let compostion = self.composition(trackList: trackList) {
            return self.exportFile(type: type, assert: compostion, presetName: presetName, handle: handle)
        }

        handle(nil,"素材列表为空");
        return nil
    }
    
    /// 压缩导出音视频文件
    /// - Parameters:
    ///   - type: 导出文件类型
    ///   - fileUrl: 导出文件路径
    ///   - presetName: 导出预设样式
    ///   - handle: 回调
    static func exportFile(type: BQFileType, fileUrl: String, presetName: String, handle: @escaping ExportBlock) -> AVAssetExportSession? {
        if fileUrl.count == 0 {
            handle(nil, "资源路径不存在!")
            return nil
        }
        return self.exportFile(type: type, assert: AVAsset(url: URL(fileURLWithPath:fileUrl)), presetName: presetName, handle: handle)
    }
    
    /// 压缩导出音视频文件
    /// - Parameters:
    ///   - type: 导出文件类型
    ///   - assert: 导出文件资源
    ///   - presetName: 导出预设样式
    ///   - handle: 回调
    static func exportFile(type: BQFileType, assert: AVAsset, presetName: String, handle: @escaping ExportBlock) -> AVAssetExportSession? {
        guard let session = AVAssetExportSession(asset: assert, presetName: presetName) else {
            handle(nil, "压缩过程错误");
            return nil
        }
        session.shouldOptimizeForNetworkUse = true
        let fileType = type.avFileType()
        if session.supportedFileTypes.contains(fileType) {
            let outFilePath = "\(NSTemporaryDirectory())\\\(UUID().uuidString).\(type.rawValue)"
            if FileManager.default.fileExists(atPath: outFilePath) {
                try? FileManager.default.removeItem(atPath: outFilePath)
            }
            session.outputURL = URL(fileURLWithPath: outFilePath)
            session.exportAsynchronously {
                DispatchQueue.main.async {
                    switch session.status {
                    case .completed:
                        handle(outFilePath, nil)
                        break
                    case .failed:
                        handle(nil, "导出失败!")
                        break
                    case .cancelled:
                        handle(nil, "导出取消")
                    default:
                        break
                    }
                }
            }
            return session
        } else {
            handle(nil, "暂不支持导出该类型:\(fileType)")
            return nil
        }
    }
}
