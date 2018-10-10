//
//  UITableView+extension.swift
//  swift4.2Demo
//
//  Created by baiqiang on 2018/10/6.
//  Copyright © 2018年 baiqiang. All rights reserved.
//

import UIKit

typealias TableViewProtocol = UITableViewDelegate & UITableViewDataSource

extension UITableView {
    
    /// use this method should use loadCell to get cell
    convenience init(frame: CGRect, style: UITableView.Style, delegate: TableViewProtocol) {
        
        self.init(frame: frame, style: style)
        self.separatorStyle = .none
        self.tableFooterView = UIView()
        self.dataSource = delegate
        self.delegate = delegate
        
    }
    
    open func registerCell(cellClass: AnyClass, isNib: Bool = false) {
        
        let identifier = cellClass.description()
        
        if isNib {
            self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        } else {
            self.register(cellClass, forCellReuseIdentifier: identifier)
        }
    }
    
    /// get cell by dequeueReusableCell
    open func loadCell(cellClass: AnyClass, indexPath: IndexPath) -> UITableViewCell {
        let identifier = cellClass.description().components(separatedBy: ".").last!
        return self.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
}
