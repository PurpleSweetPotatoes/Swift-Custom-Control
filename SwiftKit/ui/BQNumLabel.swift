//
//  BQNumLabel.swift
//  swift-Test
//
//  Created by MrBai on 2017/6/29.
//  Copyright © 2017年 MrBai. All rights reserved.
//

import UIKit

class BQNumLabel: UILabel {
    
    override var text: String? {
        didSet {
            let center = self.center
            self.adjustWidthForFont()
            let width: Int = Int(self.width + 8)
            self.width = CGFloat(width % 2 == 0 ? width : width + 1)
            self.height = self.width
            self.layer.cornerRadius = self.width * 0.5
            self.center = center
        }
    }
    //MARK: - ***** initialize Method *****
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - ***** private Method *****
    private func initUI() {
        self.textAlignment = .center
        self.backgroundColor = UIColor.red
        self.textColor = UIColor.white
        self.clipsToBounds = true
        self.font = UIFont.systemFont(ofSize: 12)
    }
    //MARK: - ***** LoadData Method *****
    
    //MARK: - ***** respond event Method *****
    
    //MARK: - ***** Protocol *****
    
    //MARK: - ***** create Method *****

}
