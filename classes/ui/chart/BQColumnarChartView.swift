// *******************************************
//  File Name:      BQColumnarChartView.swift       
//  Author:         MrBai
//  Created Date:   2022/3/30 15:23
//    
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    
import UIKit

class BQColumnarChartView: BQChartView {

    //MARK: - *** Ivars
        
    private var columnars = [CALayer]()
    
    //MARK: - *** Public method
 
    //MARK: - *** Life cycle
    
    //MARK: - *** NetWork method

    //MARK: - *** Event Action

    //MARK: - *** Delegate

    //MARK: - *** Instance method

    private func getColumLayer(_ index: Int) -> CALayer {
        if index < columnars.count {
            return columnars[index]
        }
        
        let colum = CALayer()
        colum.backgroundColor = UIColor.mainColor.cgColor
        
        columnars.append(colum)
        
        return colum
    }


    //MARK: - *** UI method

    override func clearChart() {
        super.clearChart()
        columnars.forEach{ $0.removeFromSuperlayer() }
    }
    
    override func customLayer() {
        // 数据处理
        let spac = spac
        let columW = columW
        let heights = chartValues
        let vTop = textLayerTop
        let maxHeight = heights.max()!
        
        for (i, columH) in heights.enumerated() {
            let colum = getColumLayer(i)
            let height = ceil(drawH*columH/maxHeight)
            colum.frame = CGRect(x: spac + CGFloat(i) * (columW + spac), y: vTop - height, width: columW, height: height)
            layer.addSublayer(colum)
        }
    }

    // MARK: - *** Ivar Getter



}


