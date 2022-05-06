// *******************************************
//  File Name:      BQPlayerView.swift
//  Author:         MrBai
//  Created Date:   2021/6/8 9:09 AM
//
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import AVFoundation
import UIKit

public protocol BQPlayerViewDelegate: NSObjectProtocol {
    func playBtnClick(_ playV: BQPlayerView) -> Bool
    func puaseBtnClick(_ playV: BQPlayerView)
    func playItemDidEnd(_ playV: BQPlayerView)
    func playFullStatusChange(_ playV: BQPlayerView)
    func playTimeChange(_ playV: BQPlayerView)
    func playStatusChange(_ playV: BQPlayerView)
}

public class BQPlayerView: UIView {
    // MARK: - *** Ivars

    // 公共
    public private(set) var isFull: Bool = false {
        didSet {
            ctrlView.fullBtn.isSelected = isFull
        }
    }

    public private(set) var status: BQPlayerStatus = .none {
        didSet {
            if let dele = delegate {
                dele.playStatusChange(self)
            }
        }
    }

    public weak var delegate: BQPlayerViewDelegate?

    // 播放器相关
    private var player: BQPlayer = BQPlayer()
    private let playerLayer = AVPlayerLayer()
    public var ctrlView: BQPlayerCtrlView!
    private var activView: UIView!

    // 全屏
    private weak var supV: UIView?
    private var originFrame = CGRect.zero

    // MARK: - *** Public method

    @discardableResult
    public func play() -> Bool {
        var canPlay = true
        if let dele = delegate {
            canPlay = dele.playBtnClick(self)
        } else if status == .stop {
            
        }
        
        if canPlay {
            status = .playing
            player.play()
            ctrlView.isPlaying = canPlay
        }
        return canPlay
    }

    public func puase() {
        status = .puased
        ctrlView.isPlaying = false
        player.pause()

        if let dele = delegate {
            dele.puaseBtnClick(self)
        }
    }

    public func seek(time: Int) {
        player.seek(to: CMTime(value: CMTimeValue(time), timescale: 1), toleranceBefore: CMTime(value: 1, timescale: 1000), toleranceAfter: CMTime(value: 1, timescale: 1000))
    }

    public func setFull() {
        if let superV = superview {
            isFull = true
            let keyWindow = UIApplication.shared.keyWindow
            originFrame = frame
            supV = superV
            frame = superV.convert(frame, to: keyWindow)
            keyWindow?.addSubview(self)
            UIView.animate(withDuration: 0.25) { [weak self] in
                if let weakSelf = self {
                    weakSelf.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
                    weakSelf.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    weakSelf.playerLayer.frame = weakSelf.bounds
                    weakSelf.activView.center = CGPoint(x: weakSelf.size.width * 0.5, y: weakSelf.size.height * 0.5)
                    weakSelf.ctrlView.frame = weakSelf.bounds
                    weakSelf.ctrlView.adjustSubView()
                }
            }
            if let dele = delegate {
                dele.playFullStatusChange(self)
            }
        }
    }

    public func backFull() {
        if let superV = supV {
            isFull = false
            superV.addSubview(self)
            UIView.animate(withDuration: 0.25) { [weak self] in
                if let weakSelf = self {
                    weakSelf.transform = CGAffineTransform.identity
                    weakSelf.frame = weakSelf.originFrame
                    weakSelf.playerLayer.frame = weakSelf.bounds
                    weakSelf.ctrlView.frame = weakSelf.bounds
                    weakSelf.ctrlView.adjustSubView()
                    weakSelf.activView.center = CGPoint(x: weakSelf.size.width * 0.5, y: weakSelf.size.height * 0.5)
                }
            }
            if let dele = delegate {
                dele.playFullStatusChange(self)
            }
        }
    }

    public func resetUrl(url: String) {
        var src: URL?

        if url.hasPrefix("/") {
            src = URL(fileURLWithPath: url)
        } else {
            src = URL(string: url)
        }

        if let src = src {
            let item = AVPlayerItem(url: src)
            resetPlayeItem(item: item)
        }
    }
    
    public func resetPlayeItem(item: AVPlayerItem?) {
        if isFull {
            backFull()
        }
        
        player.replaceCurrentItem(with: item)
        ctrlView.resetStatus()
    }

    // MARK: - *** Life cycle

    deinit {
        BQLogger.debug("播放器界面释放")
    }

    public convenience init(frame: CGRect, url: String) {
        self.init(frame: frame)
        resetUrl(url: url)
    }
    
    public convenience init(frame: CGRect, item: AVPlayerItem?) {
        self.init(frame: frame)
        resetPlayeItem(item: item)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer.frame = bounds
        player.delegate = self
        playerLayer.player = player
        configUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - *** NetWork method

    // MARK: - *** Event Action

    // MARK: - *** Delegate

    // MARK: - *** Instance method

    // MARK: - *** UI method

    func configUI() {
        backgroundColor = .black
        layer.addSublayer(playerLayer)

        ctrlView = BQPlayerCtrlView(frame: bounds)
        ctrlView.playerV = self
        ctrlView.isHidden = true
        addSubview(ctrlView)

        activView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        activView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        activView.corner(6)
        let activ = UIActivityIndicatorView(style: .white)
        activ.frame = activView.bounds
        activ.startAnimating()
        activView.addSubview(activ)
        activView.center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        addSubview(activView)
    }
}

extension BQPlayerView: BQPlayerDelegate {
    public func bqPlayerTimeChange(time: Double) {
        if ctrlView.sliderV.isDrag { return }
        BQLogger.debug("时间改变:\(time)")
        let curTime = Int(time)
        ctrlView.sliderV.setCurrentValue(curTime)
        ctrlView.setCurrentTime(curTime)
        if let dele = delegate {
            dele.playTimeChange(self)
        }
    }

    public func bqPlayerStatusChange(status: BQPlayerStatus, totalTime: Double?) {
        BQLogger.debug("状态改变:\(status)")
        self.status = status
        if let total = totalTime, !total.isNaN {
            let time = Int(total)
            ctrlView.sliderV.maxValue = time
            ctrlView.setDuration(time)
        }
        if status == .ready {
            ctrlView.isHidden = false
            activView.isHidden = true
            bqPlayerBufferReady()
        } else if status == .fail {
            BQHudView.show("当前网络无法播放")
        } else if status == .stop {
            ctrlView.isPlaying = false
            delegate?.playItemDidEnd(self)
        }
    }

    public func bqPlayerBufferChange(value: Double?) {
        if let val = value {
            ctrlView.sliderV.setBufferValue(Int(val))
        }
    }

    public func bqPlayerBufferEmpty() {
        BQLogger.debug("正在加载中....")
    }

    public func bqPlayerBufferReady() {
        if let item = player.currentItem {
            activView.isHidden = item.isPlaybackLikelyToKeepUp
        }
    }
}

public extension BQPlayerViewDelegate {
    func playBtnClick(_: BQPlayerView) -> Bool { return true }
    func puaseBtnClick(_: BQPlayerView) {}
    func playItemDidEnd(_: BQPlayerView) {}
    func playFullStatusChange(_: BQPlayerView) {}
    func playTimeChange(_: BQPlayerView) {}
    func playStatusChange(_: BQPlayerView) {}
}
