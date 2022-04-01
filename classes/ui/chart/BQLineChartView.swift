// *******************************************
//  File Name:      BQLineChartView.swift       
//  Author:         MrBai
//  Created Date:   2022/3/31 11:44
//    
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit

class BQLineChartView: BQChartView {


    //MARK: - *** Ivars

    lazy private var lineLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 0, y: textLayerTop - drawH , width: sizeW, height: drawH)
        shapeLayer.strokeColor = UIColor.mainColor.cgColor
        shapeLayer.fillColor = shapeLayer.strokeColor
        shapeLayer.lineWidth = 1
        return shapeLayer
    }()
    
    //MARK: - *** Public method

    //MARK: - *** Life cycle
    
    //MARK: - *** NetWork method

    //MARK: - *** Event Action

    //MARK: - *** Delegate

    //MARK: - *** Instance method
    
    //MARK: - *** UI method

    override func clearChart() {
        super.clearChart()
        lineLayer.removeFromSuperlayer()
    }
    
    override func customLayer() {
        // 数据处理
        let spac = spac
        let columW = columW
        let heights = chartValues
        let lineH = lineLayer.sizeH
        let maxHeight = heights.max()!
        
        let path = UIBezierPath()

        var prePt: CGPoint? = nil
        for (i, columH) in heights.enumerated() {
            let x = spac + columW * 0.5 + CGFloat(i) * (columW + spac)
            let y = lineH - ceil(lineH*columH/maxHeight)
            let point = CGPoint(x: x, y: y)
            
            if let _ = prePt {
                path.addLine(to: point)
            } else {
                path.move(to: point)
            }
            //画点
            path.move(to: point)
            path.addArc(withCenter: point, radius: 3, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
            path.move(to: point)
            
            prePt = point
        }
        
        lineLayer.path = path.cgPath
        
        layer.addSublayer(lineLayer)
    }
    
    // MARK: - *** Ivar Getter
    
}
