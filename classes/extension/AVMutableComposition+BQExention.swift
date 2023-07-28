// *******************************************
//  File Name:      AVMutableComposition+BQExention.swift
//  Author:         MrBai
//  Created Date:   2022/3/2 2:01 PM
//
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import AVFoundation

public typealias videoComBlock = (_ fromLayer: AVMutableVideoCompositionLayerInstruction, _ toLayer: AVMutableVideoCompositionLayerInstruction, _ timeRange: CMTimeRange) -> Void

/// 自定义轨道素材对象
public struct BQAssetTrack {
    /// 素材资源
    public private(set) var track: AVAssetTrack!

    /// 素材使用区间
    public private(set) var insertRange: CMTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTime.zero)

    /// 素材插入时间点
    public private(set) var atTime = CMTime.zero

    public var secods: Double {
        return track?.asset?.duration.seconds ?? 0
    }

    public var lastTime: Double {
        return atTime.seconds + insertRange.duration.seconds
    }

    public init(_ forTrack: AVAssetTrack) {
        track = forTrack
        insertRange = CMTimeRangeMake(start: CMTime.zero, duration: forTrack.asset?.duration ?? CMTime.zero)
    }

    /// 设置素材插入区间
    /// - Parameters:
    ///   - start: 起点
    ///   - duration: 时长
    public mutating func setTrackRange(start: Double, duration: Double) {
        assert((track?.asset?.duration.seconds ?? 100000000 - start) >= duration, "取样区间不在素材区间范围内")
        insertRange = CMTimeRangeMake(start: CMTime(duration), duration: CMTime(duration))
    }

    /// 设置素材插入时间点
    public mutating func setInsertTime(time: Double) {
        atTime = CMTime(time)
    }
}

public extension AVMutableComposition {
    /// 生成素材合成样本,可用于试看
    /// - Parameter trackList: 素材列表
    func addTracks(trackList: [BQAssetTrack]) {
        for bqTrack in trackList {
            addTrack(bqTrack)
        }
    }

    /// 生成轨道并返回可变轨道
    /// - Parameter bqTrack: 自定义轨道素材
    /// - Returns: 可变素材轨道
    @discardableResult
    func addTrack(_ bqTrack: BQAssetTrack) -> AVMutableCompositionTrack? {
        if let comTrack = addMutableTrack(withMediaType: bqTrack.track.mediaType, preferredTrackID: kCMPersistentTrackID_Invalid) {
            comTrack.insertTrack(bqTrack)
            return comTrack
        }
        return nil
    }

    /// 通过A、B视频轨道分别添加视频，并设置过渡动画
    /// 回调中如下使用
    /// 动画配置
    /// from.setOpacityRamp(fromStartOpacity: 1, toEndOpacity: 0, timeRange: instruct.timeRange)
    /// to.setOpacityRamp(fromStartOpacity: 0, toEndOpacity: 1, timeRange: instruct.timeRange)
    /// - Parameters:
    ///   - stracks: 视频素材集合
    ///   - handle: 过渡动画设置回调
    /// - Returns:
    func videoComposition(_ tracksList: [BQAssetTrack], handle: videoComBlock) -> AVMutableVideoComposition? {
        if !tracksList.isEmpty { return nil }

        // 移除视频轨道
        for track in tracks(withMediaType: .video) {
            removeTrack(track)
        }

        // 创建视频轨道
        guard let comTrackA = addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid), let comTrackB = addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            return nil
        }

        let videoTracks = [comTrackA, comTrackB]
        for (index, bqStarck) in tracksList.enumerated() {
            let videoTrack = videoTracks[index % 2]
            videoTrack.insertTrack(bqStarck)
        }

        let videoCom = AVMutableVideoComposition(propertiesOf: self)
        var index = 0
        for instruction in videoCom.instructions {
            if let instruct = instruction as? AVMutableVideoCompositionInstruction, instruct.layerInstructions.count > 1 {
                var fromLayer = instruct.layerInstructions.first as! AVMutableVideoCompositionLayerInstruction
                var toLayer = instruct.layerInstructions.last as! AVMutableVideoCompositionLayerInstruction
                if index % 2 == 1 {
                    let temp = fromLayer
                    fromLayer = toLayer
                    toLayer = temp
                }
                index += 1
                handle(fromLayer, toLayer, instruct.timeRange)
            }
        }

        return videoCom
    }

    /// 单轨道，素材拼接
    /// - Parameter stracks: 轨道素材
    func mergeStracks(_ tracksList: [BQAssetTrack]) {
        if !tracksList.isEmpty { return }

        // 移除素材轨道
        for track in tracks(withMediaType: tracksList.first!.track.mediaType) {
            removeTrack(track)
        }

        // 创建素材轨道
        guard let comTrack = addMutableTrack(withMediaType: tracksList.first!.track.mediaType, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            return
        }

        // 轨道插入素材
        for bqStrack in tracksList where bqStrack.track.mediaType == .video {
            comTrack.insertTrack(bqStrack)
        }
    }
}

public extension AVMutableCompositionTrack {
    /// 插入素材轨道
    func insertTrack(_ bqTrack: BQAssetTrack) {
        do {
            try insertTimeRange(bqTrack.insertRange, of: bqTrack.track, at: bqTrack.atTime)
        } catch {
            print("插入素材失败")
        }
    }
}

public extension CMTime {
    init(_ time: Double) {
        self.init(value: Int64(time * 600), timescale: 600)
    }
}
