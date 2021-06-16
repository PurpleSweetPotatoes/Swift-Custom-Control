// *******************************************
//  File Name:      BQPlayerView.swift       
//  Author:         MrBai
//  Created Date:   2021/6/8 9:09 AM
//    
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit
import AVFoundation

enum PlayerStatus {
    case none
    case ready
    case playing
    case puased
    case stop
}

protocol BQPlayerViewDelegate: NSObjectProtocol {
    func playBtnClick(_ playV: BQPlayerView) -> Bool
    func puaseBtnClick(_ playV: BQPlayerView)
    func playItemDidEnd(_ playV: BQPlayerView)
    func playFullStatusChange(_ playV: BQPlayerView)
    func playTimeChange(_ playV: BQPlayerView)
    func playStatusChange(_ playV: BQPlayerView)
}

extension BQPlayerViewDelegate {
    func playBtnClick(_ playV: BQPlayerView) -> Bool { return true }
    func puaseBtnClick(_ playV: BQPlayerView) {}
    func playItemDidEnd(_ playV: BQPlayerView) {}
    func playFullStatusChange(_ playV: BQPlayerView) {}
    func playTimeChange(_ playV: BQPlayerView) {}
    func playStatusChange(_ playV: BQPlayerView) {}
}

class BQPlayerView: UIView {

    //MARK: - *** Ivars
    // 公共
    private(set) public var isFull: Bool = false {
        didSet {
            ctrlView.fullBtn.isSelected = isFull
        }
    }
    private(set) public var status: PlayerStatus = .none {
        didSet {
            if let dele = delegate {
                dele.playStatusChange(self)
            }
        }
    }
    public weak var delegate: BQPlayerViewDelegate?
    
    // 播放器相关
    private var player: AVPlayer!
    private let playerLayer = AVPlayerLayer()
    public var ctrlView: BQPlayerCtrlView!
    private var activView: UIView!
    
    // 监听
    private var kvoList = [NSKeyValueObservation?]()
    private var timeKvo: Any?
    
    // 全屏
    private var supV: UIView = UIView()
    private var originFrame: CGRect = CGRect.zero
    
    //MARK: - *** Public method
    @discardableResult
    public func play() -> Bool {
        var canPlay = true
        if let dele = delegate {
            canPlay = dele.playBtnClick(self)
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
        isFull = true
        let keyWindow = UIApplication.shared.keyWindow
        originFrame = self.frame
        supV = self.superview!
        frame = supV.convert(frame, to: keyWindow)
        keyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.25) {[weak self] in
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
    
    public func backFull() {
        isFull = false
        supV.addSubview(self)
        UIView.animate(withDuration: 0.25) {[weak self] in
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
    
    public func resetUrl(url: String) {
        var src: URL?
        
        if url.hasPrefix("/") {
            src = URL(fileURLWithPath: url)
        } else {
            src = URL(string: url)
        }
        
        if let src = src {
            player = AVPlayer(url:src)
            playerLayer.player = player
            status = .none
            addObserverInfo()
        }
    }
    
    //MARK: - *** Life cycle
    deinit {
        BQLog("播放器释放")
        
        for observer in kvoList {
            if let kvo = observer {
                kvo.invalidate()
            }
        }
        kvoList.removeAll()
        
        NotificationCenter.default.removeObserver(self)
        
        if let kv = timeKvo {
            player.removeTimeObserver(kv)
        }
        
    }
    
    public convenience init(frame: CGRect, url: String) {
        self.init(frame: frame)
        resetUrl(url: url)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer.frame = bounds
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    //MARK: - *** NetWork method

    //MARK: - *** Event Action

    //MARK: - *** Delegate

    //MARK: - *** Instance method
    private func addObserverInfo() {
        if let item = player.currentItem {
            
            kvoList.append(item.observe(\.status, options: [.new]) {[weak self] item, value in
                self?.playerStatusChange()
            })
            
            kvoList.append(item.observe(\.loadedTimeRanges, options: [.new]) {[weak self] item, value in
                self?.bufferChangeHandle()
            })
            
            kvoList.append(item.observe(\.isPlaybackBufferEmpty, options: [.new]) {[weak self] item, value in
                self?.playBufferEmpty()
            })
            
            kvoList.append(item.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) {[weak self] item, value in
                self?.playBufferReady()
            })
            
            if let kv = timeKvo {
                player.removeTimeObserver(kv)
            }
            
            timeKvo = player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: nil) {[weak self] time in
                if let weakSelf = self {
                    if weakSelf.ctrlView.sliderV.isDrag { return }
                    let curTime = Int(time.seconds)
                    weakSelf.ctrlView.sliderV.setCurrentValue(curTime)
                    weakSelf.ctrlView.setCurrentTime(curTime)
                    
                    if let dele = weakSelf.delegate {
                        dele.playTimeChange(weakSelf)
                    }
                }
                
            }
        }
    }

    private func playerStatusChange() {
        if player.status == .readyToPlay {
            status = .ready
            ctrlView.isHidden = false
            activView.isHidden = true
            playBufferReady()
            if let item = player.currentItem {
                if item.duration.seconds.isNaN {
                    BQLog("获取总时长失败")
                    return
                }
                let times = Int(item.duration.seconds)
                ctrlView.sliderV.maxValue = times
                ctrlView.setDuration(times)
            }
        }
    }
    
    private func bufferChangeHandle() {
        if let item = player.currentItem, let value = item.loadedTimeRanges.first {
        
            let time = value.timeRangeValue
            let start = time.start.seconds
            let duration = time.duration.seconds
            let all = Int(start + duration)
            ctrlView.sliderV.setBufferValue(all)
        }
    }
    
    @objc private func playerIsEnd() {
        BQLog("播放完毕")
        status = .stop
        if let dele = delegate {
            dele.playItemDidEnd(self)
        }
    }
    
    private func playBufferEmpty() {
        
        if let item = player.currentItem {
            BQLog("正在加载中....\(item.isPlaybackBufferEmpty)")
        }
    }
    
    private func playBufferReady() {
        if let item = player.currentItem {
            activView.isHidden = item.isPlaybackLikelyToKeepUp
        }
    }
    
    //MARK: - *** UI method

    private func configUI() {
        backgroundColor = .black
        layer.addSublayer(playerLayer)
        
        ctrlView = BQPlayerCtrlView(frame: bounds)
        ctrlView.playerV = self
        ctrlView.isHidden = true
        addSubview(ctrlView)
        
        activView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        activView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        activView.setCorner(readius: 6)
        let activ = UIActivityIndicatorView(style: .white)
        activ.frame = activView.bounds
        activ.startAnimating()
        activView.addSubview(activ)
        activView.center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        addSubview(activView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerIsEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
}

extension Int {
    public func hmsStr() -> String {
        let seconds = self % 60
        let min = self / 60
        let hour = self / 3600
        return String(format: "%02zd:%02zd:%02zd", hour, min, seconds)
    }
    
    public func msStr() -> String {
        let seconds = self % 60
        let min = self / 60
        return String(format: "%02zd:%02zd", min, seconds)
    }
}
