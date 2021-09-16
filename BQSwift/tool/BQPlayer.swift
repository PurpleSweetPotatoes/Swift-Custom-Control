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
    public var bqStatus: BQPlayerStatus = .none

    public weak var delegate: BQPlayerDelegate?

    private var kvoList = [NSKeyValueObservation?]()
    private var timeKvo: Any?
    private var playerStatusKvo: NSKeyValueObservation?

    /// 时间改变回调间隔 value/timescale = seconds，默认1s回调一次
    public var hookTime: CMTime! {
        willSet {
            if let kv = timeKvo {
                removeTimeObserver(kv)
            }
        }
        didSet {
            timeKvo = addPeriodicTimeObserver(forInterval: hookTime, queue: nil) { [weak self] time in
                if let weakSelf = self {
                    weakSelf.delegate?.bqPlayerTimeChange(time: time.seconds)
                }
            }
        }
    }

    deinit {
        cleanObserver()
    }

    override init() {
        super.init()
        bqStatus = .none
        playerStatusKvo = observe(\.timeControlStatus, options: [.new]) { [weak self] _, _ in
            self?.bqPlayStatusChange()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playerIsEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        hookTime = CMTime(value: 1, timescale: 1)
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
        bqStatus = .none
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

        if let kv = timeKvo {
            removeTimeObserver(kv)
        }
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
            bqStatus = .playing
        } else if timeControlStatus == .paused {
            bqStatus = .puased
        } else {
            bqStatus = .wait
        }
        delegate?.bqPlayerStatusChange(status: bqStatus, totalTime: nil)
    }

    private func itemStatusChange() {
        if let item = currentItem {
            var total: Double?
            if status == .readyToPlay {
                bqStatus = .ready
                if item.duration.seconds.isNormal {
                    total = item.duration.seconds
                }
            } else if status == .failed {
                bqStatus = .fail
            }
            delegate?.bqPlayerStatusChange(status: bqStatus, totalTime: total)
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

    @objc private func playerIsEnd() {
        BQLogger.log("播放完毕")
        bqStatus = .stop
        if let dele = delegate {
            dele.bqPlayerStatusChange(status: bqStatus, totalTime: nil)
        }
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
