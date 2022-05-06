// *******************************************
//  File Name:      BQProgressView.swift
//  Author:         MrBai
//  Created Date:   2021/8/19 4:33 PM
//
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import UIKit

public enum BQProgressType {
    case circle // 原型
}

public class BQProgressView: UIView {
    // MARK: - *** Ivars

    private var type = BQProgressType.circle
    private var bgLayer = CAShapeLayer()
    private var colorLayer = CAShapeLayer()
    private var numLab = UILabel()

    // MARK: - *** Public method

    public func setProgressNum(recive: Int, total: Int) {
        if recive >= 0, recive <= total {
            let all = (total != 0 ? total : 1)
            let percent = recive * 100 / all
            if type == .circle {
                let colorPath = UIBezierPath(arcCenter: CGPoint(x: sizeW * 0.5, y: sizeH * 0.5), radius: sizeW * 0.5, startAngle: 1.5 * CGFloat.pi, endAngle: 1.5 * CGFloat.pi + 2 * CGFloat.pi * CGFloat(percent) / 100.0, clockwise: true)
                colorLayer.path = colorPath.cgPath
            }
            numLab.text = "\(percent)%"
        }
    }

    // MARK: - *** Life cycle

    public convenience init(frame: CGRect, showType: BQProgressType = .circle) {
        self.init(frame: frame)
        type = showType
        configUI()
    }

    override private init(frame: CGRect) {
        super.init(frame: frame)
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
        if type == .circle {
            configCirLayer(bgLayer, storeColor: .lightGray)
            configCirLayer(colorLayer, storeColor: .white)

            let bgPath = UIBezierPath(arcCenter: CGPoint(x: sizeW * 0.5, y: sizeH * 0.5), radius: sizeW * 0.5, startAngle: -0.5 * CGFloat.pi, endAngle: 1.5 * CGFloat.pi, clockwise: true)
            bgLayer.path = bgPath.cgPath

            numLab.frame = bounds
            numLab.font = .systemFont(ofSize: 8)
            numLab.textAlignment = .center
            numLab.textColor = .white
            numLab.text = "0%"
        }

        layer.addSublayer(bgLayer)
        layer.addSublayer(colorLayer)
        addSubview(numLab)
    }

    private func configCirLayer(_ fromLayer: CAShapeLayer, storeColor: UIColor) {
        fromLayer.frame = bounds
        fromLayer.lineWidth = 4
        fromLayer.strokeColor = storeColor.cgColor
        fromLayer.lineCap = .round
        fromLayer.fillColor = UIColor.clear.cgColor
    }
}
