// *******************************************
//  File Name:      BQPlayerCtrlView.swift       
//  Author:         MrBai
//  Created Date:   2021/6/9 11:12 AM
//    
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit
import AVFoundation
import MediaPlayer

private let animationTime = 0.5

class BQPlayerCtrlView: UIView {

    //MARK: - *** Ivars
    public let sliderV = BQPlayerSliderView(frame: CGRect.zero)
    public let playBtn = UIButton(type: .custom)
    public let fullBtn = UIButton(type: .custom)
    weak public var playerV: BQPlayerView?
    public var voiceSlider: UISlider!
    public var isPlaying: Bool = false {
        didSet {
            playBtn.isSelected = isPlaying
        }
    }
    
    
    private let topLab = UILabel()
    private let bottomV = UIView()
    private let currentTimeLab = UILabel()
    private let allTimeLab = UILabel()
    private var isShow: Bool = true
    private let tipV = BQPlayerTipView(frame: CGRect(x: 0, y: 0, width: 80, height: 50))
    
    private var hideBlock: TaskBlock?
    private var autoPlay: Bool = false
    
    // 手势
    private var _startPoint: CGPoint = CGPoint.zero
    private var _showValue: CGFloat = 0.0
    
    private var updown = false
    private var isLeft = false
    
    //MARK: - *** Public method
    
    public func setCurrentTime(_ num: Int) {
        currentTimeLab.text = num.msStr()
    }
    
    public func setDuration(_ num: Int) {
        allTimeLab.text = num.msStr()
    }
    
    public func setTopTitle(str: String) {
        topLab.text = str
    }
    
    public func adjustSubView() {
        topLab.frame = CGRect(x: 0, y: 0, width: size.width, height: 40)
        var left:CGFloat = 10
        if let play = playerV, play.isFull {
            left = UIApplication.shared.statusBarFrame.height
        }
        bottomV.frame = CGRect(x: 0, y: size.height - 40, width: size.width, height: 40)
        playBtn.frame = CGRect(x: left, y: 0, width: bottomV.size.height, height: bottomV.size.height)
        currentTimeLab.frame = CGRect(x: playBtn.right, y: playBtn.top, width: 55, height: playBtn.size.height)
        fullBtn.frame = CGRect(x: size.width - playBtn.right, y: playBtn.top, width: playBtn.size.width, height: playBtn.size.height)
        allTimeLab.frame = CGRect(x: fullBtn.left - 55, y: playBtn.top, width: 55, height: playBtn.size.height)
        sliderV.frame = CGRect(x: currentTimeLab.right + 8, y: 0, width: allTimeLab.left - currentTimeLab.right - 16, height: bottomV.size.height)
        sliderV.adjustSubView()
        
        tipV.center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        
        if let play = playerV, play.isFull {
            tipV.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } else {
            tipV.transform = CGAffineTransform.identity
        }
    }
    
    public func show() {
        isShow = true
        let lowf = size.height
        UIView.animate(withDuration: animationTime) { [weak self] in
            self?.topLab.top = 0
            self?.bottomV.bottom = lowf
        } completion: {[weak self] result in
            self?.delayHide()
        }
    }
    
    public func hide() {
        
        if let block = hideBlock {
            DispatchQueue.cancel(task: block)
        }
        
        isShow = false
        let topf = size.height
        UIView.animate(withDuration: animationTime) { [weak self] in
            self?.topLab.bottom = 0
            self?.bottomV.top = topf
        }
    }
    
    //MARK: - *** Life cycle
    
    deinit {
        if let v = voiceSlider.superview, let _ = v.superview {
            v.removeFromSuperview()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
        addGestrueHandle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - *** NetWork method
    
    //MARK: - *** Event Action
    @objc private func playBtnClick(sender: UIButton) {
        BQLog("播放按钮点击")
        if let player = playerV {
            if !sender.isSelected {
                player.play()
            } else {
                player.puase()
            }
        }
        delayHide()
    }
    
    @objc public func fullBtnClick(sender: UIButton) {
        if let player = playerV {
            if !sender.isSelected {
                player.setFull()
            } else {
                player.backFull()
            }
        }
        delayHide()
    }
    
    //MARK: - *** Delegate

    //MARK: - *** Instance method
 
    private func delayHide() {
        if let block = hideBlock {
            DispatchQueue.cancel(task: block)
        }
        if isPlaying {
            hideBlock = DispatchQueue.delay(4) { [weak self] in
                self?.hide()
            }
        }
    }
    
    public func loadVolumeView() -> UIView {
        let volumeV = MPVolumeView(frame: CGRect.zero)
        volumeV.alpha = 0.0001
        for subV in volumeV.subviews {
            if NSStringFromClass(subV.classForCoder) == "MPVolumeSlider" {
                voiceSlider = subV as! UISlider
                break
            }
        }
        return volumeV as UIView
    }
    //MARK: - *** UI method

    private func configUI() {
        configTopView()
        configBottomView()
        addSubview(tipV)
        tipV.alpha = 0
        adjustSubView()
        
        clipsToBounds = true
    }
    
    private func configTopView() {
        topLab.textAlignment = .center
        topLab.textColor = .white
        topLab.font = .systemFont(ofSize: 15)
        topLab.text = "测试标题"
        topLab.backgroundColor = UIColor(white: 0, alpha: 0.3)
        addSubview(topLab)
    }

    private func configBottomView() {

        bottomV.backgroundColor = topLab.backgroundColor
        
        playBtn.setImage(UIImage.playIcon(), for: .normal)
        playBtn.setImage(UIImage.puaseIcon(), for: .selected)
        playBtn.addTarget(self, action: #selector(playBtnClick), for: .touchUpInside)
        bottomV.addSubview(playBtn)
        
        configLab(lab: currentTimeLab)
        bottomV.addSubview(currentTimeLab)
        
    
        fullBtn.backgroundColor = .clear
        fullBtn.setImage(UIImage.fullIcon(), for: .normal)
        fullBtn.setImage(UIImage.noFullIcon(), for: .selected)
        fullBtn.addTarget(self, action: #selector(fullBtnClick), for: .touchUpInside)
        bottomV.addSubview(fullBtn)
        
        allTimeLab.frame = CGRect(x: fullBtn.left - 55, y: playBtn.top, width: 55, height: playBtn.size.height)
        configLab(lab: allTimeLab)
        bottomV.addSubview(allTimeLab)
                
        sliderV.delegate = self
        bottomV.addSubview(sliderV)
        addSubview(bottomV)
    }
    
    private func configLab(lab: UILabel) {
        lab.textAlignment = .center
        lab.textColor = .white
        lab.font = UIFont(name: "Helvetica Neue", size: 13)
        lab.text = "00:00"
    }
    
}

// MARK: - 进度条协议
extension BQPlayerCtrlView: BQPlayerSliderViewProtocol {
    func sliderStartChange() {
        if let block = hideBlock {
            DispatchQueue.cancel(task: block)
        }
        setCurrentTime(sliderV.currentValue)
        autoPlay = false
        if let player = playerV, player.status == .playing {
            autoPlay = true
            player.puase()
        }
    }
    
    func sliderDidChange() {
        setCurrentTime(sliderV.currentValue)
    }
    
    func sliderEndChange() {
        setCurrentTime(sliderV.currentValue)
        playerV?.seek(time: sliderV.currentValue)
        delayHide()
        if let player = playerV, autoPlay {
            autoPlay = false
            player.play()
        }
    }
        
}


// MARK: - 手势处理部分
extension BQPlayerCtrlView {
    
    private func addGestrueHandle() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGetureClick))
        addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGetureAction))
        addGestureRecognizer(pan)
    }
    
    @objc private func tapGetureClick() {
        if isShow {
            hide()
        } else {
            show()
        }
    }
    
    @objc private func panGetureAction(sender: UIPanGestureRecognizer) {
        let state = sender.state
        
        if (state == .began) {
            let translation = sender.translation(in: self)
            updown = abs(translation.x) < abs(translation.y)
            _startPoint = sender.location(in: self)
            isLeft = _startPoint.x <= size.width * 0.5
            tipV.alpha = 1
            if updown {
                if isLeft { // 亮度
                    tipV.config(.bright, maxV: 1.0)
                    _showValue = UIScreen.main.brightness
                } else { // 音量
                    _showValue = CGFloat(voiceSlider.value)
                    tipV.config(.voice, maxV: 1.0)
                }
            } else {
                _showValue = CGFloat(sliderV.currentValue)
                tipV.config(.lab, maxV: CGFloat(sliderV.maxValue))
            }
            tipV.setValue(_showValue)
            
        } else {
            let currentPoint = sender.location(in: self)
            let value = updown ? (_showValue + (_startPoint.y - currentPoint.y) / size.height * 0.8) :  (_showValue + (currentPoint.x - _startPoint.x) * 0.1)
            
            tipV.setValue(value)
            
            let disValue = tipV.curValue()
            
            if sender.state == .changed {
                // 边界情况
                if tipV.isBoundary() {
                    _startPoint = currentPoint
                    _showValue = CGFloat(tipV.curValue())
                }
                
                if updown {
                    if isLeft { // 亮度
                        UIScreen.main.brightness = disValue
                    } else { // 音量
                        voiceSlider.value = Float(disValue)
                    }
                }
                
            } else { // 消失动画
                
                UIView.animate(withDuration: 0.25) {[weak self] in
                    if let weakSelf = self {
                        weakSelf.tipV.alpha = 0
                    }
                }
                
                if !updown && Int(disValue) != sliderV.currentValue {
                    playerV?.seek(time: Int(disValue))
                }
                
                if let player = playerV, autoPlay {
                    autoPlay = false
                    player.play()
                }
            }
        }
    
    }
    
}

// MARK: - 图标绘制
extension UIImage {
    public static func playIcon(size: CGSize = CGSize(width: 18, height: 18)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale);
        let context = UIGraphicsGetCurrentContext()
        let space: CGFloat = size.width * 0.1
        context?.move(to: CGPoint(x: space, y: 0))
        context?.addLine(to: CGPoint(x: space, y: size.height))
        context?.addLine(to: CGPoint(x: size.width, y: size.height * 0.5))
        context?.addLine(to: CGPoint(x: space, y: 0))
        context?.closePath()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fillPath()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img ?? UIImage()
    }
    
    public static func puaseIcon(size: CGSize = CGSize(width: 20, height: 20)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale);
        let context = UIGraphicsGetCurrentContext()
        let space: CGFloat = size.width * 0.1
        context?.move(to: CGPoint(x: size.width * 0.3, y: space))
        context?.addLine(to: CGPoint(x: size.width * 0.3, y: size.height - space))
        context?.move(to: CGPoint(x: size.width * 0.7, y: space))
        context?.addLine(to: CGPoint(x: size.width * 0.7, y: size.height - space))
        context?.setLineCap(.round)
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.strokePath()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img ?? UIImage()
    }
    
    public static func fullIcon(size: CGSize = CGSize(width: 20, height: 20)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale);
        let context = UIGraphicsGetCurrentContext()
        let lineW = size.width * 0.3
        
        context?.move(to: CGPoint(x: lineW, y: 1))
        context?.addLine(to: CGPoint(x: 1, y: 1))
        context?.addLine(to: CGPoint(x: 1, y: lineW))
        
        context?.move(to: CGPoint(x: lineW, y: size.height - 1))
        context?.addLine(to: CGPoint(x: 1, y: size.height - 1))
        context?.addLine(to: CGPoint(x: 1, y: size.height - lineW))
        
        context?.move(to: CGPoint(x: size.width - lineW, y: 1))
        context?.addLine(to: CGPoint(x: size.width - 1, y: 1))
        context?.addLine(to: CGPoint(x: size.width - 1, y: lineW))
        
        context?.move(to: CGPoint(x: size.width - 1, y: size.height - lineW))
        context?.addLine(to: CGPoint(x: size.width - 1, y: size.height - 1))
        context?.addLine(to: CGPoint(x: size.width - lineW, y: size.height - 1))
        context?.setFillColor(UIColor.clear.cgColor)
        context?.setLineCap(.round)
        context?.setLineJoin(.round)
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.strokePath()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img ?? UIImage()
    }
    
    public static func noFullIcon(size: CGSize = CGSize(width: 20, height: 20)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale);
        let context = UIGraphicsGetCurrentContext()
        let lineW = size.width * 0.3
        
        context?.move(to: CGPoint(x: lineW, y: 0))
        context?.addLine(to: CGPoint(x: lineW, y: lineW))
        context?.addLine(to: CGPoint(x: 0, y: lineW))
        
        context?.move(to: CGPoint(x: lineW, y: size.height))
        context?.addLine(to: CGPoint(x: lineW, y: size.height - lineW))
        context?.addLine(to: CGPoint(x: 0, y: size.height - lineW))
        
        context?.move(to: CGPoint(x: size.width - lineW, y: 0))
        context?.addLine(to: CGPoint(x: size.width - lineW, y: lineW))
        context?.addLine(to: CGPoint(x: size.width, y: lineW))
        
        context?.move(to: CGPoint(x: size.width, y: size.height - lineW))
        context?.addLine(to: CGPoint(x: size.width - lineW, y: size.height - lineW))
        context?.addLine(to: CGPoint(x: size.width - lineW, y: size.height))
        
        context?.setLineCap(.round)
        context?.setLineJoin(.round)
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.strokePath()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img ?? UIImage()
    }
    
    public static func volumeIcon(size: CGSize = CGSize(width: 20, height: 20)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale);
        let context = UIGraphicsGetCurrentContext()
        
        let lineW = size.width * 0.3
        let top = (size.height - lineW) * 0.5
        context?.move(to: CGPoint(x: lineW, y: top))
        context?.addLine(to: CGPoint(x: lineW, y: top + lineW))
        context?.addLine(to: CGPoint(x: 0, y: top + lineW))
        context?.addLine(to: CGPoint(x: 0, y: top))
        context?.addLine(to: CGPoint(x: lineW, y: top))
        
        context?.addLine(to: CGPoint(x: size.width - lineW * 0.5, y: 0))
        context?.addLine(to: CGPoint(x: size.width - lineW * 0.5, y: size.height))
        context?.addLine(to: CGPoint(x: lineW, y: top + lineW))
        
        
        context?.setLineCap(.round)
        context?.setLineJoin(.round)
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.strokePath()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img ?? UIImage()
    }
    
    public static func noVolumeIcon(size: CGSize = CGSize(width: 20, height: 20)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale);
        let context = UIGraphicsGetCurrentContext()
        
        let lineW = size.width * 0.3
        let top = (size.height - lineW) * 0.5
        context?.move(to: CGPoint(x: lineW, y: top))
        context?.addLine(to: CGPoint(x: lineW, y: top + lineW))
        context?.addLine(to: CGPoint(x: 0, y: top + lineW))
        context?.addLine(to: CGPoint(x: 0, y: top))
        context?.addLine(to: CGPoint(x: lineW, y: top))
        
        context?.addLine(to: CGPoint(x: size.width - lineW * 0.5, y: 0))
        context?.addLine(to: CGPoint(x: size.width - lineW * 0.5, y: lineW * 0.5))
        context?.move(to: CGPoint(x: size.width - lineW * 0.5, y: size.height - lineW * 0.5))
        context?.addLine(to: CGPoint(x: size.width - lineW * 0.5, y: size.height))
        context?.addLine(to: CGPoint(x: lineW, y: top + lineW))
        
        context?.move(to: CGPoint(x: lineW + 5, y: top))
        context?.addLine(to: CGPoint(x: size.width - lineW * 0.5, y: top + lineW))
        
        context?.move(to: CGPoint(x: size.width - lineW * 0.5 , y: top))
        context?.addLine(to: CGPoint(x: lineW + 5, y: top + lineW))
        
        context?.setLineCap(.round)
        context?.setLineJoin(.round)
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.strokePath()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img ?? UIImage()
    }
    
    public static func forwardIcon(size: CGSize = CGSize(width: 20, height: 15)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale);
        let context = UIGraphicsGetCurrentContext()
        
        context?.move(to: CGPoint(x: size.width * 0.5, y: size.height * 0.5))
        context?.addLine(to: CGPoint(x: 1, y: 1))
        context?.addLine(to: CGPoint(x: 1, y: size.height))
        context?.addLine(to: CGPoint(x: size.width * 0.5 , y: size.height * 0.5))
        context?.addLine(to: CGPoint(x: size.width * 0.5, y: 1))
        
        context?.addLine(to: CGPoint(x: size.width - 1, y: size.height * 0.5))
        context?.addLine(to: CGPoint(x: size.width * 0.5, y: size.height - 1))
        context?.addLine(to: CGPoint(x: size.width * 0.5, y: size.height * 0.5))
        
        context?.setLineCap(.round)
        context?.setLineJoin(.round)
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.strokePath()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img ?? UIImage()
    }
    
    public static func backwardIcon(size: CGSize = CGSize(width: 20, height: 15)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale);
        let context = UIGraphicsGetCurrentContext()
        
        context?.move(to: CGPoint(x: size.width * 0.5, y: size.height * 0.5))
        context?.addLine(to: CGPoint(x: size.width - 1, y: 1))
        context?.addLine(to: CGPoint(x: size.width - 1, y: size.height - 1))
        context?.addLine(to: CGPoint(x: size.width * 0.5, y: size.height * 0.5))
        context?.addLine(to: CGPoint(x: size.width * 0.5, y: 1))
        
        context?.addLine(to: CGPoint(x: 1, y: size.height * 0.5))
        context?.addLine(to: CGPoint(x: size.width * 0.5, y: size.height - 1))
        context?.addLine(to: CGPoint(x: size.width * 0.5, y: size.height * 0.5))
        
        context?.setLineCap(.round)
        context?.setLineJoin(.round)
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.strokePath()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img ?? UIImage()
    }
    
    public static func brightIcon(size: CGSize = CGSize(width: 24, height: 24)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale);
        let context = UIGraphicsGetCurrentContext()
        
        context?.setLineCap(.round)
        context?.setLineJoin(.round)
        context?.setStrokeColor(UIColor.white.cgColor)
        
        // 画圆
        context?.setLineWidth(1)
        context?.addArc(center: CGPoint(x: size.width * 0.5, y: size.height * 0.5), radius: 5, startAngle: CGFloat.pi, endAngle: -CGFloat.pi, clockwise: true)
        context?.strokePath()
        
        for _ in 0..<9 {
            context?.move(to: CGPoint(x: size.width * 0.5, y: 1))
            context?.addLine(to: CGPoint(x: size.width * 0.5, y: 4))
            context?.translateBy(x: size.width * 0.5, y: size.height * 0.5)
            context?.rotate(by: CGFloat.pi * 0.25)
            context?.translateBy(x: -size.width * 0.5, y: -size.height * 0.5)
        }
        context?.strokePath()
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img ?? UIImage()
    }
    
}
