//
//  UITableView+extension.swift
//  QiShou-App
//
//  Created by MrBai on 2017/6/6.
//  Copyright © 2017年 MrBai. All rights reserved.
//

import UIKit

typealias TableViewProtocol = UITableViewDelegate & UITableViewDataSource

extension UITableView {
    
    /// use this method should use loadCell to get cell
    convenience init(frame: CGRect, style: UITableViewStyle, delegate: TableViewProtocol) {
        self.init(frame: frame, style: style)
        self.separatorStyle = .none
        self.tableFooterView = UIView()
        self.dataSource = delegate
        self.delegate = delegate
    }
    
    open func registerCell(cellClass: AnyClass, isNib: Bool = false) {
        let identifier = cellClass.description().components(separatedBy: ".").last!
        if isNib {
            self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        }else {
            self.register(cellClass, forCellReuseIdentifier: identifier)
        }
    }
    
    /// get cell by dequeueReusableCell
    open func loadCell(cellClass: AnyClass, indexPath: IndexPath) -> UITableViewCell {
        let identifier = cellClass.description().components(separatedBy: ".").last!
        return self.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
}
