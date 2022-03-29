// *******************************************
//  File Name:      BQDrawView.swift
//  Author:         MrBai
//  Created Date:   2021/6/7 3:05 PM
//
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import UIKit

/// 绘画视图
class BQDrawView: UIView {
    // MARK: - *** Ivars

    private var drawLayer = CAShapeLayer() // 展示层
    private var drawPath = UIBezierPath() // 线路
    private let dottedLayer = CAShapeLayer() // 边界框
    // 线宽
    public var lineW: CGFloat = 4.0 {
        didSet {
            drawLayer.lineWidth = lineW
        }
    }

    // 线条颜色
    public var lineColor: UIColor = .black {
        didSet {
            drawLayer.strokeColor = lineColor.cgColor
        }
    }

    private var hasDraw = false // 已经作画
    private var isOut = false // 超出界限

    // MARK: - *** Public method

    public func showDottedBorad(width: CGFloat = 2.0, color: UIColor = .lightGray) {
        dottedLayer.isHidden = false
        dottedLayer.lineWidth = width
        dottedLayer.strokeColor = color.cgColor
    }

    public func hideDottedBorad() {
        dottedLayer.isHidden = true
    }

    public func getImage() -> UIImage? {
        let state = dottedLayer.isHidden
        dottedLayer.isHidden = true
        let img = hasDraw ? snapshoot() : nil
        dottedLayer.isHidden = state
        return img
    }

    public func reset() {
        drawPath.removeAllPoints()
        drawLayer.path = drawPath.cgPath
        hasDraw = false
        
    }

    // MARK: - *** Life cycle

    override public init(frame: CGRect) {
        super.init(frame: frame)
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

    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        let point = touches.first!.location(in: self)
        drawPath.move(to: point)
        hasDraw = true
        isOut = false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        let point = touches.first!.location(in: self)

        if bounds.contains(point) {
            if isOut {
                drawPath.move(to: point)
                isOut = false
            } else {
                drawPath.addLine(to: point)
            }
            drawLayer.path = drawPath.cgPath
        } else {
            isOut = true
        }
    }

    // MARK: - *** UI method

    func configUI() {
        dottedLayer.isHidden = true
        dottedLayer.fillColor = UIColor.clear.cgColor
        dottedLayer.lineDashPattern = [8, 5]
        let path = UIBezierPath(rect: bounds)
        dottedLayer.path = path.cgPath
        layer.addSublayer(dottedLayer)

        drawLayer.frame = bounds
        drawLayer.strokeColor = lineColor.cgColor
        drawLayer.lineWidth = lineW
        drawLayer.fillColor = UIColor.clear.cgColor
        drawLayer.lineCap = .round
        drawLayer.lineJoin = .round

        layer.addSublayer(drawLayer)
    }
}
