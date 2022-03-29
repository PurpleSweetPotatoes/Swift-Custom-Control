// *******************************************
//  File Name:      BQPlayer.swift
//  Author:         MrBai
//  Created Date:   2021/9/16 4:46 PM
//
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import AVFoundation

enum BQPlayerStatus {
    case none
    case ready
    case playing
    case puased
    case wait
    case stop
    case fail
}

/// 播放器代理
protocol BQPlayerDelegate: NSObjectProtocol {
    /// 状态改变
    func bqPlayerStatusChange(status: BQPlayerStatus, totalTime: Double?)

    /// 缓冲进度改变
    /// - Parameter value: 缓冲总进度
    func bqPlayerBufferChange(value: Double?)

    /// 无缓冲进度
    func bqPlayerBufferEmpty()

    /// 缓冲进度已完成可播放
    func bqPlayerBufferReady()

    /// 播放时间改变
    /// - Parameter time: 时间进度
    func bqPlayerTimeChange(time: Double)
}

class BQPlayer: AVPlayer {
    
    public var bqStatus: BQPlayerStatus = .none {
        didSet {
            delegate?.bqPlayerStatusChange(status: bqStatus, totalTime: self.duration)
        }
    }

    public weak var delegate: BQPlayerDelegate?

    /// 时间改变回调间隔 value/timescale = seconds，默认1s回调一次
    public var hookTime: CMTime = CMTime.zero {
        willSet {
            if let kv = timeKvo {
                removeTimeObserver(kv)
            }
        }
        didSet {
            timeKvo = addPeriodicTimeObserver(forInterval: hookTime, queue: nil) { [weak self] time in
                if let weakSelf = self {
                    weakSelf.delegate?.bqPlayerTimeChange(time: time.seconds)
                    if weakSelf.bqStatus == .stop && weakSelf.currentTime().seconds == weakSelf.duration {
                        weakSelf.bqStatus = .puased
                    }
                }
            }
        }
    }
    
    private var kvoList = [NSKeyValueObservation?]()
    private var timeKvo: Any?
    private var playerStatusKvo: NSKeyValueObservation?
    private var duration: Double {
        return currentItem?.duration.seconds ?? 0
    }

    override func play() {
        if hookTime == CMTime.zero {
            hookTime = CMTime(value: 1, timescale: 1)
        }
        super.play()
    }
    
    public func replay() {
        if currentItem != nil {
            seek(to: CMTime.zero)
            play()
        }
    }
    
    deinit {
        BQLogger.log("视频层移除")
        cleanObserver()
        if let kv = timeKvo {
            removeTimeObserver(kv)
        }
    }

    override init() {
        super.init()
        bqStatus = .none
        playerStatusKvo = observe(\.timeControlStatus, options: [.new]) { [weak self] _, _ in
            self?.bqPlayStatusChange()
        }
    }

    override init(url URL: URL) {
        super.init(url: URL)
    }

    override init(playerItem item: AVPlayerItem?) {
        super.init(playerItem: item)
        addObserverInfo()
    }

    override func replaceCurrentItem(with item: AVPlayerItem?) {
        cleanObserver()
        self.bqStatus = .none
        super.replaceCurrentItem(with: item)
        addObserverInfo()
    }

    private func cleanObserver() {
        for observer in kvoList {
            if let kvo = observer {
                kvo.invalidate()
            }
        }
        kvoList.removeAll()
    }

    private func addObserverInfo() {
        if let item = currentItem {
            kvoList.append(item.observe(\.status, options: [.new]) { [weak self] _, _ in
                self?.itemStatusChange()
            })

            kvoList.append(item.observe(\.loadedTimeRanges, options: [.new]) { [weak self] _, _ in
                self?.bufferChange()
            })

            kvoList.append(item.observe(\.isPlaybackBufferEmpty, options: [.new]) { [weak self] _, _ in
                self?.delegate?.bqPlayerBufferEmpty()
            })

            kvoList.append(item.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] _, _ in
                self?.delegate?.bqPlayerBufferReady()
            })
        }
    }

    // MARK: - 监听逻辑处理

    private func bqPlayStatusChange() {
        if timeControlStatus == .playing {
            self.bqStatus = .playing
        } else if timeControlStatus == .paused {
            self.bqStatus = currentTime().seconds == self.duration ? .stop : .puased
        } else {
            self.bqStatus = .wait
        }
    }

    private func itemStatusChange() {
        if let _ = currentItem {
            if status == .readyToPlay {
                self.bqStatus = .ready
            } else if status == .failed {
                self.bqStatus = .fail
            }
        }
    }

    private func bufferChange() {
        var total: Double?
        if let item = currentItem, let value = item.loadedTimeRanges.first {
            let time = value.timeRangeValue
            let start = time.start.seconds
            let duration = time.duration.seconds
            total = start + duration
        }
        delegate?.bqPlayerBufferChange(value: total)
    }
}

// MARK: - 代理方法默认实现

extension BQPlayerDelegate {
    func bqPlayerStatusChange(status: BQPlayerStatus, totalTime: Double?) {
        BQLogger.log("当前状态:\(status),总时长:\(String(describing: totalTime))")
    }

    func bqPlayerBufferChange(value: Double?) {
        BQLogger.log("缓存进度改变:\(String(describing: value))")
    }

    func bqPlayerBufferEmpty() {
        BQLogger.log("无缓存可用")
    }

    func bqPlayerBufferReady() {
        BQLogger.log("有缓存可用")
    }

    func bqPlayerTimeChange(time: Double) {
        BQLogger.log("播放时间改变:\(time)")
    }
}

public extension Int {
    func hmsStr() -> String {
        let seconds = self % 60
        let min = self / 60
        let hour = self / 3600
        return String(format: "%02zd:%02zd:%02zd", hour, min, seconds)
    }

    func msStr() -> String {
        let seconds = self % 60
        let min = self / 60
        return String(format: "%02zd:%02zd", min, seconds)
    }
}
