// *******************************************
//  File Name:      UITableView+BQExtension.swift       
//  Author:         MrBai
//  Created Date:   2019/8/15 2:29 PM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************
    

import UIKit

typealias TableViewProtocol = UITableViewDelegate & UITableViewDataSource

protocol EmptyViewProtocol: NSObjectProtocol {
    
    ///用以判断是会否显示空视图
    func showEmtpyView(tableView: UITableView) -> Bool
    
    ///配置空数据提示图用于展示
    func configEmptyView(tableView: UITableView) -> UIView
}

private var kEmptyViewDelegate = ""
private let emptyViewTag: Int = 350132706
private let systemAccessoryWidths:[CGFloat] = [0,34,68,40,48]

extension UITableView {
    
    //MARK:- ***** Public Method *****
    
    /// convenience method use config tableView has no separator
    convenience init(frame: CGRect, style: UITableView.Style, delegate: TableViewProtocol) {
        
        self.init(frame: frame, style: style)
        self.separatorStyle = .none
        self.tableFooterView = UIView()
        self.dataSource = delegate
        self.delegate = delegate
        
    }
    
    open func getCellName(cellClass: AnyClass) -> String {
        return cellClass.description().components(separatedBy: ".").last!
    }
    
    /// register cell by cellClass
    open func registerCell(cellClass: AnyClass, isNib: Bool = false) {
        
        let identifier = self.getCellName(cellClass: cellClass)
        
        if isNib {
            self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        } else {
            self.register(cellClass, forCellReuseIdentifier: identifier)
        }
    }
    
    /// get cell by dequeueReusableCell
    open func loadCell(cellClass: AnyClass, indexPath: IndexPath) -> UITableViewCell {
        return self.dequeueReusableCell(withIdentifier: self.getCellName(cellClass: cellClass), for: indexPath)
    }
    
    private func loadTemplateCell(identifier: String) -> UITableViewCell {
        
        var templateCells = objc_getAssociatedObject(self,#function) as? [String: UITableViewCell]
        if templateCells == nil {
            templateCells = [String: UITableViewCell]()
            objc_setAssociatedObject(self, #function, templateCells, .OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
        
        var cell = templateCells![identifier]
        if cell == nil {
            cell = self.dequeueReusableCell(withIdentifier: identifier)
            assert(cell != nil, "Cell must be registered to table view for identifier - \(identifier)")
            templateCells![identifier] = cell!
        }
        
        return cell!
    }
    
    
    /// cell height not from NSLayoutConstraint can use this method, becase tableView use estimatedRowHeight to  autofetch cellheight
    open func fetchCellHeight(cellClass: AnyClass, configBlock:(_ cell: UITableViewCell) -> Void) -> CGFloat {
        let cell = self.loadTemplateCell(identifier: self.getCellName(cellClass: cellClass))
        
        configBlock(cell)
        
        var fittingHeight:CGFloat = 0
        
        var contentViewWidth = self.bounds.width
        if let accessoryView = cell.accessoryView {
            contentViewWidth -= (16 + accessoryView.bounds.width);
        } else {
            contentViewWidth -= systemAccessoryWidths[cell.accessoryType.rawValue];
        }
        
        let widthFenceConstraint = NSLayoutConstraint(item: cell.contentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: contentViewWidth)
        widthFenceConstraint.priority = UILayoutPriority.required - 1
        
        let leftConstraint = NSLayoutConstraint(item: cell.contentView, attribute: .left, relatedBy: .equal, toItem: cell, attribute: .left, multiplier: 1.0, constant: contentViewWidth)
        let rightConstraint = NSLayoutConstraint(item: cell.contentView, attribute: .right, relatedBy: .equal, toItem: cell, attribute: .right, multiplier: 1.0, constant: contentViewWidth)
        let topConstraint = NSLayoutConstraint(item: cell.contentView, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1.0, constant: contentViewWidth)
        let bottomConstraint = NSLayoutConstraint(item: cell.contentView, attribute: .bottom, relatedBy: .equal, toItem: cell, attribute: .bottom, multiplier: 1.0, constant: contentViewWidth)
        let edgeConstraint = [leftConstraint, rightConstraint, topConstraint, bottomConstraint]
        cell.addConstraints(edgeConstraint)
        cell.contentView.addConstraint(widthFenceConstraint)
        
        fittingHeight = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        
        cell.contentView.removeConstraint(widthFenceConstraint)
        cell.removeConstraints(edgeConstraint)
        
        if (self.separatorStyle != .none) {
            fittingHeight += (1.0 / UIScreen.main.scale)
        }
        
        return max(cell.bounds.height, fittingHeight)
    }
    
    
    func setEmtpyViewDelegate(target: EmptyViewProtocol) {
        self.emptyDelegate = target
        DispatchQueue.once(token:#function) {
            BQTool.exchangeMethod(cls: self.classForCoder, targetSel: #selector(self.layoutSubviews), newSel: #selector(self.re_layoutSubviews))
        }
    }
    
    @objc func re_layoutSubviews() {
        self.re_layoutSubviews()
        
        self.viewWithTag(emptyViewTag)?.removeFromSuperview()
        
        if let delegate = self.emptyDelegate {
            if delegate.showEmtpyView(tableView: self) {
                let emptyView = delegate.configEmptyView(tableView: self)
                emptyView.tag = emptyViewTag
                self.addSubview(emptyView)
            }
        }
        
    }
    
    private var emptyDelegate: EmptyViewProtocol? {
        get {
            return (objc_getAssociatedObject(self, &kEmptyViewDelegate) as? EmptyViewProtocol)
        }
        set (newValue){
            objc_setAssociatedObject(self, &kEmptyViewDelegate, newValue!, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
}

extension EmptyViewProtocol {
    func configEmptyView() -> UIView {
        return UIView()
    }
}

