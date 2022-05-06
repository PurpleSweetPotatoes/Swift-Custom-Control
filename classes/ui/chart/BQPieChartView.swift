// *******************************************
//  File Name:      BQPieChartView.swift
//  Author:         MrBai
//  Created Date:   2022/4/1 11:07
//    
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit

public class BQPieChartView: BQChartView {


    //MARK: - *** Ivars
    
    public var lineW: CGFloat = 0;
    
    /// 环装图
    private var pieLayers = [CAShapeLayer]()
    
    /// 环状图结束点
    private var layerEnds = [CGFloat]()
    
    private lazy var centerLab: UILabel = {
        return creatCenterLab()
    }()
    //MARK: - *** Public method
    
    //MARK: - *** Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        lineW = sizeW * 0.22
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureChartClick(sender:)))
        addGestureRecognizer(tap)
        
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - *** NetWork method

    //MARK: - *** Event Action
    
    @objc private func tapGestureChartClick(sender: UITapGestureRecognizer) {
        let pt = sender.location(in: self)
        
        let cPt = CGPoint(x: sizeW * 0.5, y: sizeH * 0.5)
        let space = CGPoint.distance(cPt, to: pt)
        
        // 在圆环内
        if space >= (sizeW * 0.5 - lineW) && space <= sizeW * 0.5 {
            let agnle = CGPoint.agnle(pt, centerPt: cPt)
            
            let endAgnle = Int(agnle * 180 / CGFloat.pi + 90) % 360
            let end = CGFloat(endAgnle) / 360.0
            for (i, layerEnd) in layerEnds.enumerated() {
                if layerEnd >= end {
                    let name = delegate.chartItemDesc(self, index: i)
                    let precent = Int((layerEnd - pieLayers[i].strokeStart) * 10000)
                    centerLab.text = "\(name) \(precent.toDecimalStr())%\n\(chartValues[i])"
                    centerLab.sizeToFit()
                    centerLab.frame = CGRect(x: (sizeW - centerLab.sizeW - 6) * 0.5, y: (sizeH - centerLab.sizeH - 6) * 0.5, width: centerLab.sizeW + 6, height: centerLab.sizeH + 6)
                    return
                }
            }
        }
    }
    
    //MARK: - *** Delegate

    //MARK: - *** Instance method

    private func getPieLayer(_ index: Int) -> CAShapeLayer {
        if index < pieLayers.count {
            return pieLayers[index]
        }
        let lay = CAShapeLayer()
        lay.strokeColor = UIColor.randomColor.cgColor
        lay.lineWidth = lineW
        lay.fillColor = UIColor.clear.cgColor
        pieLayers.append(lay)
        return lay
    }
    
    //MARK: - *** UI method

    func configUI() {
        addSubview(centerLab)
    }
    
    override func clearChart() {
        super.clearChart()
        layerEnds.removeAll()
    }
    
    override func customLayer() {
        clearChart()
        // 数据
        let heights = chartValues
        let sum = heights.reduce(0, {$0 + $1}) + spac * CGFloat(num)
        let spac = spac / sum
        let scales = heights.map { $0 / sum }
        
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: sizeW * 0.5, y: sizeW * 0.5), radius: sizeW * 0.5 - lineW*0.5, startAngle: CGFloat.pi*1.5, endAngle: CGFloat.pi*3.5, clockwise: true)
        
        var endAngle: CGFloat = 0
        
        for (i, angle) in scales.enumerated() {
            let lay = getPieLayer(i)
            lay.strokeStart = endAngle
            lay.strokeEnd = endAngle + angle
            lay.path = path.cgPath
            layer.addSublayer(lay)
            endAngle = lay.strokeEnd + spac
            layerEnds.append(endAngle)
        }
    }
    
    // MARK: - Ivar Getter
    
    private func creatCenterLab() -> UILabel {
        let lab = UILabel(frame: CGRect.zero, font: .systemFont(ofSize: 15), text: "", textColor: .black, alignment: .center)
        lab.numberOfLines = 0
        return lab
    }
    
}
