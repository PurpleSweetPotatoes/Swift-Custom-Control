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
    func showEmptyView(tableView: UITableView) -> Bool
    
    ///配置空数据提示图用于展示
    func configEmptyView(tableView: UITableView) -> UIView
}

extension EmptyViewProtocol {
    func configEmptyView() -> UIView {
        return UIView()
    }
}


extension UITableView {
    
    //MARK:- ***** Public Method *****
    
    /// convenience method use config tableView has no separator
    convenience init(frame: CGRect, style: UITableView.Style, delegate: TableViewProtocol) {
        
        self.init(frame: frame, style: style)
        self.separatorStyle = .none
        self.tableFooterView = UIView()
        self.estimatedRowHeight = 50
        self.dataSource = delegate
        self.delegate = delegate
    }

    func setEmtpyViewDelegate(target: EmptyViewProtocol) {
        self.emptyDelegate = target
        DispatchQueue.once(token:#function) {
            UITableView.exchangeMethod(targetSel: #selector(layoutSubviews), newSel: #selector(re_layoutSubviews))
        }
    }
    
    @objc func re_layoutSubviews() {
        self.re_layoutSubviews()
        if let delegate = self.emptyDelegate {
            if delegate.showEmptyView(tableView: self) {
                
                let emptyView = delegate.configEmptyView(tableView: self)
                let emptyViewTag = 10231343
                
                if let v = self.viewWithTag(emptyViewTag), v != emptyView {
                    v.removeFromSuperview()
                }
                
                if emptyView.superview == nil {
                    emptyView.tag = emptyViewTag
                    self.addSubview(emptyView)
                }
            }
        }
    }
    
    //MARK:- ***** Associated Object *****
    
    private struct AssociatedKeys {
        static var emptyDelegateKey: Void?
    }
    
    private var emptyDelegate: EmptyViewProtocol? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.emptyDelegateKey) as? EmptyViewProtocol)
        }
        set (newValue){
            objc_setAssociatedObject(self, &AssociatedKeys.emptyDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
}


extension UITableViewCell {
    /// 获取cell标示符，标示符为cell名称
    public static func getCellName() -> String {
        return self.description().components(separatedBy: ".").last!
    }
    
    /// 注册cell
    public static func register(to tableV: UITableView, isNib: Bool = false) {
        let identifier = getCellName()
        if isNib {
            tableV.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        } else {
            tableV.register(self, forCellReuseIdentifier: identifier)
        }
    }
    
    /// 加载cell
    public static func load(from tableV: UITableView, indexPath: IndexPath) -> Self {
        return tableV.dequeueReusableCell(withIdentifier: getCellName(), for: indexPath) as! Self
    }
    
    /// 加载临时cell用于计算cell相关属性并缓存
    public static func loadTempleteCell(from tableV: UITableView) -> Self {
        return tableV.dequeueReusableCell(withIdentifier: getCellName()) as! Self
    }
    
    /// 获取cell的最大高度(layout和frame对比)
    public func fetchCellHeight(from tableV: UITableView) -> CGFloat {
    
        var fittingHeight:CGFloat = 0
        
        var contentViewWidth = tableV.bounds.width
        if let accessoryView = self.accessoryView {
            contentViewWidth -= (16 + accessoryView.bounds.width);
        } else {
            let systemAccessoryWidths:[CGFloat] = [0,34,68,40,48]
            contentViewWidth -= systemAccessoryWidths[self.accessoryType.rawValue];
        }
        
        let widthFenceConstraint = NSLayoutConstraint(item: self.contentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: contentViewWidth)
        widthFenceConstraint.priority = UILayoutPriority.required - 1
        
        let leftConstraint = NSLayoutConstraint(item: self.contentView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: contentViewWidth)
        let rightConstraint = NSLayoutConstraint(item: self.contentView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: contentViewWidth)
        let topConstraint = NSLayoutConstraint(item: self.contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: contentViewWidth)
        let bottomConstraint = NSLayoutConstraint(item: self.contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: contentViewWidth)
        let edgeConstraint = [leftConstraint, rightConstraint, topConstraint, bottomConstraint]
        self.addConstraints(edgeConstraint)
        self.contentView.addConstraint(widthFenceConstraint)
        
        fittingHeight = self.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        
        self.contentView.removeConstraint(widthFenceConstraint)
        self.removeConstraints(edgeConstraint)
        
        if (tableV.separatorStyle != .none) {
            fittingHeight += (1.0 / UIScreen.main.scale)
        }
        
        return max(self.bounds.height, fittingHeight)
    }
    
}


#if canImport(MJRefresh)
import MJRefresh

extension UITableView {
    func addHeaderRefresh(block:@escaping VoidBlock) {
        let head = MJRefreshNormalHeader(refreshingBlock: block)
        self.mj_header = head
    }
    
    func addFooterRefresh(block:@escaping VoidBlock) {
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: block)
        self.mj_footer = footer
    }
}

#endif
