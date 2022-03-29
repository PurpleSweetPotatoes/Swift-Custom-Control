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
    /// 用以判断是会否显示空视图
    func showEmptyView(tableView: UITableView) -> Bool

    /// 配置空数据提示图用于展示
    func configEmptyView(tableView: UITableView) -> UIView
}

extension EmptyViewProtocol {
    func configEmptyView() -> UIView {
        return UIView()
    }
}

extension UITableView {
    // MARK: - ***** Public Method *****

    /// convenience method use config tableView has no separator
    convenience init(frame: CGRect, style: UITableView.Style, delegate objc: TableViewProtocol) {
        self.init(frame: frame, style: style)
        separatorStyle = .none
        tableFooterView = UIView()
        estimatedRowHeight = 50
        dataSource = objc
        delegate = objc
        
        if #available(iOS 15.0, *) {
            sectionHeaderTopPadding = 0
        }
    }

    func setEmtpyViewDelegate(target: EmptyViewProtocol) {
        emptyDelegate = target
        DispatchQueue.once(token: #function) {
            UITableView.exchangeMethod(targetSel: #selector(layoutSubviews), newSel: #selector(re_layoutSubviews))
        }
    }

    @objc func re_layoutSubviews() {
        re_layoutSubviews()
        if let delegate = emptyDelegate {
            
            let emptyViewTag = 10_231_343
            
            if delegate.showEmptyView(tableView: self) {
                let emptyView = delegate.configEmptyView(tableView: self)
                
                if let v = viewWithTag(emptyViewTag) {
                    if emptyView == v {
                        v.isHidden = false
                    } else {
                        v.removeFromSuperview()
                    }
                }

                if emptyView.superview == nil {
                    emptyView.tag = emptyViewTag
                    addSubview(emptyView)
                }
            } else {
                if let v = viewWithTag(emptyViewTag){
                    v.isHidden = true
                }
            }
        }
    }
    
    // MARK: - ***** Associated Object *****

    private enum AssociatedKeys {
        static var emptyDelegateKey: Void?
    }

    private var emptyDelegate: EmptyViewProtocol? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.emptyDelegateKey) as? EmptyViewProtocol)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.emptyDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

// MARK:- 链式编程
public extension UITableView {

    // MARK: 2.1、设置 delegate 代理
    /// 设置 delegate 代理
    /// - Parameter delegate: delegate description
    /// - Returns: 返回自身
   @discardableResult
    func delegate(_ delegate: UITableViewDelegate) -> Self {
        self.delegate = delegate
        return self
    }

    // MARK: 2.2、设置 dataSource 代理
    /// 设置 dataSource 代理
    /// - Parameter dataSource: dataSource description
    /// - Returns: 返回自身
    @discardableResult
    func dataSource(_ dataSource: UITableViewDataSource) -> Self {
        self.dataSource = dataSource
        return self
    }

    // MARK: 2.3、设置行高
    /// 设置行高
    /// - Parameter height: 行高
    /// - Returns: 返回自身
    @discardableResult
    func rowHeight(_ height: CGFloat) -> Self {
        self.rowHeight = height
        return self
    }

    // MARK: 2.4、设置段头(sectionHeaderHeight)的高度
    /// 设置段头(sectionHeaderHeight)的高度
    /// - Parameter height: 段头的高度
    /// - Returns: 返回自身
    @discardableResult
    func sectionHeaderHeight(_ height: CGFloat) -> Self {
        self.sectionHeaderHeight = height
        return self
    }

    // MARK: 2.5、设置段尾(sectionHeaderHeight)的高度
    /// 设置段尾(sectionHeaderHeight)的高度
    /// - Parameter height: 段尾的高度
    /// - Returns: 返回自身
    @discardableResult
    func sectionFooterHeight(_ height: CGFloat) -> Self {
        self.sectionFooterHeight = height
        return self
    }

    // MARK: 2.6、设置一个默认cell高度
    /// 设置一个默认cell高度
    /// - Parameter height: 默认cell高度
    /// - Returns: 返回自身
    @discardableResult
    func estimatedRowHeight(_ height: CGFloat) -> Self {
        self.estimatedRowHeight = height
        return self
    }

    // MARK: 2.7、设置默认段头(estimatedSectionHeaderHeight)高度
    /// 设置默认段头(estimatedSectionHeaderHeight)高度
    /// - Parameter height: 段头高度
    /// - Returns: 返回自身
    @discardableResult
    func estimatedSectionHeaderHeight(_ height: CGFloat) -> Self {
        self.estimatedSectionHeaderHeight = height
        return self
    }

    // MARK: 2.8、设置默认段尾(estimatedSectionFooterHeight)高度
    /// 设置默认段尾(estimatedSectionFooterHeight)高度
    /// - Parameter height: 段尾高度
    /// - Returns: 返回自身
    @discardableResult
    func estimatedSectionFooterHeight(_ height: CGFloat) -> Self {
        self.estimatedSectionFooterHeight = height
        return self
    }

    // MARK: 2.9、设置分割线的样式
    /// 设置分割线的样式
    /// - Parameter style: 分割线的样式
    /// - Returns: 返回自身
    @discardableResult
    func separatorStyle(_ style: UITableViewCell.SeparatorStyle = .none) -> Self {
        self.separatorStyle = style
        return self
    }

    // MARK: 2.10、设置 UITableView 的头部 tableHeaderView
    /// 设置 UITableView 的头部 tableHeaderView
    /// - Parameter head: 头部 View
    /// - Returns: 返回自身
    @discardableResult
    func tableHeaderView(_ head: UIView?) -> Self {
        self.tableHeaderView = head
        return self
    }

    // MARK: 2.11、设置 UITableView 的尾部 tableFooterView
    /// 设置 UITableView 的尾部 tableFooterView
    /// - Parameter foot: 尾部 View
    /// - Returns: 返回自身
    @discardableResult
    func tableFooterView(_ foot: UIView?) -> Self {
        self.tableFooterView = foot
        return self
    }

    // MARK: 2.12、滚动到第几个IndexPath
    /// 滚动到第几个IndexPath
    /// - Parameters:
    ///   - indexPath: 第几个IndexPath
    ///   - scrollPosition: 滚动的方式
    ///   - animated: 是否要动画
    /// - Returns: 返回自身
    @discardableResult
    func scroll(to indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition = .middle, animated: Bool = true) -> Self {
        if indexPath.section < 0 || indexPath.row < 0 || indexPath.section > self.numberOfSections || indexPath.row > self.numberOfRows (inSection: indexPath.section) {
            return self
        }
        scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
        return self
    }

    // MARK: 2.13、滚动到第几个row、第几个section
    /// 滚动到第几个row、第几个section
    /// - Parameters:
    ///   - row: 第几 row
    ///   - section: 第几 section
    ///   - scrollPosition: 滚动的方式
    ///   - animated: 是否要动画
    /// - Returns: 返回自身
    @discardableResult
    func scroll(row: Int, section: Int = 0, at scrollPosition: UITableView.ScrollPosition = .middle, animated: Bool = true) -> Self {
        return scroll(to: IndexPath.init(row: row, section: section), at: scrollPosition, animated: animated)
    }

    // MARK: 2.14、滚动到最近选中的cell（选中的cell消失在屏幕中，触发事件可以滚动到选中的cell）
    /// 滚动到最近选中的cell（选中的cell消失在屏幕中，触发事件可以滚动到选中的cell）
    /// - Parameters:
    ///   - scrollPosition: 滚动的方式
    ///   - animated: 是否要动画
    /// - Returns: 返回自身
    @discardableResult
    func scrollToNearestSelectedRow(scrollPosition: UITableView.ScrollPosition = .middle, animated: Bool = true) -> Self {
        scrollToNearestSelectedRow(at: scrollPosition, animated: animated)
        return self
    }
}



#if canImport(MJRefresh)
    import MJRefresh

    extension UITableView {
        func addHeaderRefresh(block: @escaping VoidBlock) {
            let head = MJRefreshNormalHeader(refreshingBlock: block)
            mj_header = head
        }

        func addFooterRefresh(block: @escaping VoidBlock) {
            let footer = MJRefreshAutoNormalFooter(refreshingBlock: block)
            mj_footer = footer
        }
    }

#endif
