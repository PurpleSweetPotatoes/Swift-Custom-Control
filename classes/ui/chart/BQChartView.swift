// *******************************************
//  File Name:      BQChartView.swift       
//  Author:         MrBai
//  Created Date:   2022/3/31 10:48
//    
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit

protocol BQChartViewDelegate: NSObjectProtocol {
    
    /// 图形数据个数
    func chartDataCount(_ columV: BQChartView) -> Int
    
    /// 图形数据间距
    func chartItemSpace(_ columV: BQChartView) -> CGFloat
    
    /// 图像数据值
    func chartItemValue(_ columV: BQChartView, index: Int) -> CGFloat
        
    /// 下标值 饼状图无效
    func chartItemDesc(_ columV: BQChartView, index: Int) -> String

}


class BQChartView: UIView {

    //MARK: - *** Ivars
        
    final private var dashLayers: [CAShapeLayer]!
    final private var baseTextLayers = [CATextLayer]()
    final private var columHs = [CGFloat]()
    
    public var delegate: BQChartViewDelegate!
    
    /// 底部文字高度
    var textLayerTop: CGFloat { return sizeH - 20 }
    
    /// 图表数量
    var num: Int { return delegate.chartDataCount(self) }
    
    /// 图表间距
    var spac: CGFloat { return delegate.chartItemSpace(self) }
    
    /// 图表宽度
    var columW: CGFloat { return (sizeW - CGFloat(num + 1) * spac) / CGFloat(num) }
    
    /// 图表数据集
    var chartValues: [CGFloat] {
        return (0..<num).map { delegate.chartItemValue(self, index: $0) }
    }
    
    /// 画图区域高度
    var drawH: CGFloat { return textLayerTop * 0.8 }
    
    //MARK: - *** Public method
    
    public func reload() {
        clearChart()
        configChart()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        reload()
    }
    
    //MARK: - *** Life cycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .groupTableViewBackground
        
        dashLayers = (0..<3).map { index in return CALayer.dashLayer(frame: CGRect(x: 0, y: 0, width: sizeW, height: 1), color: .mainColor, dashPattern: [5,5]) }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - *** NetWork method

    //MARK: - *** Event Action

    //MARK: - *** Delegate

    //MARK: - *** Instance method

    func customLayer() {}
    
    private func getTextLayer(_ index: Int) -> CATextLayer {
        if index < baseTextLayers.count {
            return baseTextLayers[index]
        }
        
        let textLayer = CATextLayer()
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.fontSize = 10
        textLayer.alignmentMode = .center
        textLayer.contentsScale = UIScreen.main.scale
        
        baseTextLayers.append(textLayer)
        
        return textLayer
    }


    //MARK: - *** UI method

    func clearChart() {
        dashLayers.forEach { $0.removeFromSuperlayer() }
        baseTextLayers.forEach{ $0.removeFromSuperlayer() }
    }
    
    private func configChart() {
        // 数据处理
        let heights = chartValues
        
        let vTop = textLayerTop
        let topH = drawH
        let dashSpac = topH / CGFloat(dashLayers.count - 1)
        
        // 虚线layer
        for (i, clayer) in dashLayers.enumerated() {
            let layerH = topH - CGFloat(i) * dashSpac
            clayer.frame = CGRect(x: 0, y: vTop - layerH, width: sizeW, height: layerH)
            layer.addSublayer(clayer)
        }
        
        // 底部描述layer
        for i in 0..<heights.count where i % 3 == 0 || i + 1 == num {
            let left = spac * 0.5 + CGFloat(i) * (columW + spac)
            let j = Int(ceil(CGFloat(i) / 3.0))
            let textLayer = getTextLayer(j)
            textLayer.frame = CGRect(x: left , y: vTop, width: columW + spac, height: 20)
            textLayer.string = delegate.chartItemDesc(self, index:i)
            layer.addSublayer(textLayer)
        }
        
        // 自定义部分
        customLayer()
    }

    // MARK: - *** Ivar Getter

}

extension BQChartViewDelegate {
    func chartDataCount(_ columV: BQChartView) -> Int { return 12 }
    
    func chartItemSpace(_ columV: BQChartView) -> CGFloat {return 8.0}
    
    func chartItemValue(_ columV: BQChartView, index: Int) -> CGFloat { return columV.bounds.size.height * 0.5}
    
    func chartItemDesc(_ columV: BQChartView, index: Int) -> String { return "\(index)"}
}
