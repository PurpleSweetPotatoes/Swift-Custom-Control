// *******************************************
//  File Name:      BQPlayTipView.swift
//  Author:         MrBai
//  Created Date:   2021/6/10 9:34 PM
//
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import UIKit

enum PlayTipType: Int {
    case voice
    case bright
    case lab
}

class BQPlayerTipView: UIView {
    // MARK: - *** Ivars

    private let slider = BQPlayerSliderView(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
    private let imgV = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
    private let tipLab = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
    private let imgs: [UIImage] = [
        UIImage.volumeIcon(),
        UIImage.brightIcon(),
        UIImage.noVolumeIcon(),
    ]
    public var type = PlayTipType.voice

    // MARK: - *** Public method

    public func config(_ ty: PlayTipType, maxV: CGFloat) {
        type = ty
        imgV.isHidden = type == .lab
        tipLab.isHidden = !imgV.isHidden
        slider.maxValue = Int(maxV * 100)
    }

    public func setValue(_ v: CGFloat) {
        var resultV = Int(v * 100)
        if resultV < 0 {
            resultV = 0
        } else if resultV > slider.maxValue {
            resultV = slider.maxValue
        }
        slider.setCurrentValue(resultV)

        if type == .lab {
            tipLab.text = String(format: "%@/%@", (resultV / 100).msStr(), (slider.maxValue / 100).msStr())
        } else if type == .voice {
            imgV.image = resultV == 0 ? imgs.last : imgs.first
        } else if type == .bright {
            imgV.image = imgs[1]
        }
    }

    public func curValue() -> CGFloat {
        return CGFloat(slider.currentValue) / CGFloat(100.0)
    }

    public func isBoundary() -> Bool {
        return slider.currentValue == 0 || slider.currentValue == slider.maxValue
    }

    // MARK: - *** Life cycle

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
        backgroundColor = UIColor(white: 0, alpha: 0.6)
        setCorner(readius: 4)
        isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - *** NetWork method

    // MARK: - *** Event Action

    // MARK: - *** Delegate

    // MARK: - *** Instance method

    private func updateSlider() {}

    // MARK: - *** UI method

    private func configUI() {
        addSubview(imgV)
        addSubview(tipLab)
        addSubview(slider)

        imgV.center = CGPoint(x: size.width * 0.5, y: 20)
        imgV.contentMode = .scaleAspectFit
        imgV.image = imgs.first

        tipLab.sizeW = size.width
        tipLab.font = UIFont(name: "Helvetica Neue", size: 12)
        tipLab.textAlignment = .center
        tipLab.textColor = .white
        tipLab.center = imgV.center

        slider.frame = CGRect(x: 5, y: imgV.bottom + 5, width: size.width - 10, height: 10)
        slider.thumbV.isHidden = true
        slider.adjustSubView()
    }
}
