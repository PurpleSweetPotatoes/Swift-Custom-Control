//
//  UITableView+extension.swift
//  QiShou-App
//
//  Created by MrBai on 2017/6/6.
//  Copyright © 2017年 MrBai. All rights reserved.
//

import UIKit

enum Cellkeys: String {
    case system = "UITableViewCell"
    case test = "BQTestcell"
}


typealias TableViewProtocol = UITableViewDelegate & UITableViewDataSource

extension UITableView {
    
    /// use this method should use loadCell to get cell
    convenience init(frame: CGRect, style: UITableViewStyle, identifier: Cellkeys, delegate: TableViewProtocol) {
        self.init(frame: frame, style: style)
        self.separatorStyle = .none
        if identifier == .system {
            self.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: identifier.rawValue)
        }else {
            self.register(UINib.init(nibName: identifier.rawValue, bundle: nil), forCellReuseIdentifier: identifier.rawValue)
        }
        self.tableFooterView = UIView()
        self.dataSource = delegate
        self.delegate = delegate
    }
    
    /// get cell by dequeueReusableCell
    func loadCell(identifier: Cellkeys, indexPath: IndexPath) -> UITableViewCell {
        return self.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath)
    }
}
