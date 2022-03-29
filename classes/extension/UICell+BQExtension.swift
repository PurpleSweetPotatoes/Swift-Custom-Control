// *******************************************
//  File Name:      UICell+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2022/2/23 4:28 PM
//    
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit

extension UITableViewCell {
    /// 注册cell
    static func register(to tableV: UITableView, isNib: Bool = false) {
        let identifier = className()
        if isNib {
            tableV.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        } else {
            tableV.register(self, forCellReuseIdentifier: identifier)
        }
    }

    /// 加载cell
    static func load(from tableV: UITableView, indexPath: IndexPath) -> Self {
        return tableV.dequeueReusableCell(withIdentifier: className(), for: indexPath) as! Self
    }

    /// 加载临时cell用于计算cell相关属性并缓存
    static func loadTempleteCell(from tableV: UITableView) -> Self {
        return tableV.dequeueReusableCell(withIdentifier: className()) as! Self
    }

    /// 获取cell的最大高度(layout和frame对比)
    func fetchCellHeight(from tableV: UITableView) -> CGFloat {
        var fittingHeight: CGFloat = 0

        var contentViewWidth = tableV.bounds.width
        if let accessoryView = self.accessoryView {
            contentViewWidth -= (16 + accessoryView.bounds.width)
        } else {
            let systemAccessoryWidths: [CGFloat] = [0, 34, 68, 40, 48]
            contentViewWidth -= systemAccessoryWidths[accessoryType.rawValue]
        }

        let widthFenceConstraint = NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: contentViewWidth)
        widthFenceConstraint.priority = UILayoutPriority.required - 1

        let leftConstraint = NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: contentViewWidth)
        let rightConstraint = NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: contentViewWidth)
        let topConstraint = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: contentViewWidth)
        let bottomConstraint = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: contentViewWidth)
        let edgeConstraint = [leftConstraint, rightConstraint, topConstraint, bottomConstraint]
        addConstraints(edgeConstraint)
        contentView.addConstraint(widthFenceConstraint)

        fittingHeight = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height

        contentView.removeConstraint(widthFenceConstraint)
        removeConstraints(edgeConstraint)

        if tableV.separatorStyle != .none {
            fittingHeight += (1.0 / UIScreen.main.scale)
        }

        return max(bounds.height, fittingHeight)
    }
}

extension UITableViewHeaderFooterView {
    /// 注册 headerFooterView
    static func register(to tableV: UITableView, isNib: Bool = false) {
        let identifier = className()
        if isNib {
            tableV.register(self, forHeaderFooterViewReuseIdentifier: identifier)
        } else {
            tableV.register(self, forHeaderFooterViewReuseIdentifier: identifier)
        }
    }

    /// 加载 headerFooterView
    static func load(from tableV: UITableView) -> Self {
        return tableV.dequeueReusableHeaderFooterView(withIdentifier: className()) as! Self
    }

}

extension UICollectionViewCell {
    static func register(to collectionV: UICollectionView, isNib: Bool = false) {
        let identifier = className()
        if isNib {
            collectionV.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
        } else {
            collectionV.register(self, forCellWithReuseIdentifier: identifier)
        }
    }
    
    static func load(from collectionV: UICollectionView, indexPath: IndexPath) -> Self {
        return collectionV.dequeueReusableCell(withReuseIdentifier: className(), for: indexPath) as! Self
    }
}
