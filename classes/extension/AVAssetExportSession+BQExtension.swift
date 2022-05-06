// *******************************************
//  File Name:      AVAssetExportSession+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2021/6/23 11:26 AM
//
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import AVFoundation

public typealias ExportBlock = (_ exportUrl: String?, _ errDesc: String?) -> Void

public enum BQFileType: String {
    case mp4
    case mov
    case m4a
    case caf

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

public extension AVAssetExportSession {
    /// 压缩导出音视频文件
    /// - Parameters:
    ///   - type: 导出文件类型
    ///   - trackList: 素材列表
    ///   - presetName: 导出预设样式
    ///   - handle: 回调
    @discardableResult
    class func compositionFile(type: BQFileType, trackList: [BQAssetTrack], presetName: String = AVAssetExportPresetHighestQuality, handle: @escaping ExportBlock) -> AVAssetExportSession? {
        let compostion = AVMutableComposition()
        compostion.addTracks(trackList: trackList)
        return exportFile(type: type, assert: compostion, presetName: presetName, handle: handle)
    }

    /// 压缩导出音视频文件
    /// - Parameters:
    ///   - type: 导出文件类型
    ///   - fileUrl: 导出文件路径
    ///   - presetName: 导出预设样式
    ///   - handle: 回调
    @discardableResult
    static func exportFile(type: BQFileType, fileUrl: String, presetName: String, videoComposition: AVVideoComposition? = nil, handle: @escaping ExportBlock) -> AVAssetExportSession? {
        if fileUrl.count == 0 {
            handle(nil, "资源路径不存在!")
            return nil
        }
        return exportFile(type: type, assert: AVAsset(url: URL(fileURLWithPath: fileUrl)), presetName: presetName, videoComposition: videoComposition, handle: handle)
    }

    /// 压缩导出音视频文件
    /// - Parameters:
    ///   - type: 导出文件类型
    ///   - assert: 导出文件资源
    ///   - presetName: 导出预设样式
    ///   - handle: 回调
    @discardableResult
    static func exportFile(type: BQFileType, assert: AVAsset, presetName: String, videoComposition: AVVideoComposition? = nil, handle: @escaping ExportBlock) -> AVAssetExportSession? {
        guard let session = AVAssetExportSession(asset: assert, presetName: presetName) else {
            handle(nil, "压缩过程错误")
            return nil
        }
        session.shouldOptimizeForNetworkUse = true
        session.videoComposition = videoComposition
        let fileType = type.avFileType()
        if session.supportedFileTypes.contains(fileType) {
            session.outputFileType = fileType
            let outFilePath = "\(NSTemporaryDirectory())\(UUID().uuidString).\(type.rawValue)"
            if FileManager.default.fileExists(atPath: outFilePath) {
                try? FileManager.default.removeItem(atPath: outFilePath)
            }
            session.outputURL = URL(fileURLWithPath: outFilePath)
            session.exportAsynchronously {
                DispatchQueue.main.async {
                    switch session.status {
                    case .completed:
                        handle(outFilePath, nil)
                    case .failed:
                        handle(nil, "导出失败!")
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
