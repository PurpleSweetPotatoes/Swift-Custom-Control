// *******************************************
//  File Name:      BQPlaySliderView.swift
//  Author:         MrBai
//  Created Date:   2021/6/9 5:08 PM
//
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import UIKit

protocol BQPlayerSliderViewProtocol: NSObjectProtocol {
    func sliderStartChange()
    func sliderDidChange()
    func sliderEndChange()
}

class BQPlayerSliderView: UIView {
    // MARK: - *** Ivars

    public weak var delegate: BQPlayerSliderViewProtocol?
    public private(set) var isDrag: Bool = false
    public let bgLayer = CALayer()
    public let bufferLayer = CALayer()
    public let sliderLayer = CALayer()
    public let thumbV = UIImageView()

    public var currentValue: Int = 0
    public var bufferValue: Int = 0
    public var maxValue: Int = 100

    public var canSlider: Bool = true

    // MARK: - *** Public method

    public func setCurrentValue(_ num: Int) {
        if num >= 0, num <= maxValue, maxValue != 0 {
            currentValue = num
            changeWidth(layer: sliderLayer, value: num)
            thumbV.center = CGPoint(x: sliderLayer.sizeW, y: sliderLayer.position.y)
        }
    }

    public func setBufferValue(_ num: Int) {
        if num >= 0, num <= maxValue, maxValue != 0 {
            bufferValue = num
            changeWidth(layer: bufferLayer, value: num)
        }
    }

    public func adjustSubView() {
        bgLayer.frame = CGRect(x: 0, y: (size.height - bgLayer.size.height) * 0.5, width: size.width, height: 4)
        bufferLayer.frame = bgLayer.frame
        sliderLayer.frame = bgLayer.frame
        thumbV.center = CGPoint(x: sliderLayer.sizeW, y: sliderLayer.position.y)
        setCurrentValue(currentValue)
        setBufferValue(bufferValue)
    }

    public func reset() {
        maxValue = 100
        currentValue = 0
        bufferValue = 0
        adjustSubView()
    }

    // MARK: - *** Life cycle

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
        addGestureHandle()
        reset()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - *** NetWork method

    // MARK: - *** Event Action

    @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
        if !canSlider || maxValue == 0 { return }

        if let dg = delegate {
            dg.sliderStartChange()
        }

        let point = sender.location(in: self)
        changeWidth(layer: sliderLayer, width: point.x)

        if let dg = delegate {
            dg.sliderEndChange()
        }
        BQLogger.log("点击:\(point.x)")
    }

    @objc private func panGestureAction(sender: UIPanGestureRecognizer) {
        if !canSlider || maxValue == 0 { return }

        let point = sender.location(in: self)
        BQLogger.log("滑动:\(point.x)")
        changeWidth(layer: sliderLayer, width: point.x)

        if let dg = delegate {
            if sender.state == .began {
                isDrag = true
                dg.sliderStartChange()
            } else if sender.state == .changed {
                dg.sliderDidChange()
            } else {
                isDrag = false
                dg.sliderEndChange()
            }
        }
    }

    // MARK: - *** Delegate

    // MARK: - *** Instance method

    private func addGestureHandle() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
        addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction))
        addGestureRecognizer(pan)
    }

    private func changeWidth(layer: CALayer, width: CGFloat? = nil, value: Int? = nil) {
        var toW: CGFloat?
        if let w = width, w >= 0, w <= size.width {
            toW = w
            if layer == sliderLayer {
                currentValue = Int(w / size.width * CGFloat(maxValue))
                thumbV.center = CGPoint(x: w, y: sliderLayer.position.y)
            } else if layer == bufferLayer {
                bufferValue = Int(w / size.width * CGFloat(maxValue))
            }
        } else if let v = value {
            toW = CGFloat(v) / CGFloat(maxValue) * size.width
        }

        if let toW = toW {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer.sizeW = toW
            CATransaction.commit()
        }
    }

    // MARK: - *** UI method

    private func configUI() {
        bgLayer.backgroundColor = UIColor(white: 1, alpha: 0.3).cgColor
        bufferLayer.backgroundColor = UIColor(white: 1, alpha: 0.5).cgColor
        sliderLayer.backgroundColor = UIColor.white.cgColor

        bgLayer.cornerRadius = 2.0
        bufferLayer.cornerRadius = 2.0
        sliderLayer.cornerRadius = 2.0

        layer.addSublayer(bgLayer)
        layer.addSublayer(bufferLayer)
        layer.addSublayer(sliderLayer)

        thumbV.frame = CGRect(x: 0, y: 0, width: 12, height: 12)
        thumbV.setCorner(readius: thumbV.size.width * 0.5)
        thumbV.backgroundColor = .cyan
        addSubview(thumbV)
    }
}
