//
//  UITableView+extension.swift
//  BQRefresh
//
//  Created by MrBai on 2017/7/5.
//  Copyright © 2017年 baiqiang. All rights reserved.
//

import UIKit

private let headerRefreshTag = 100100
private let footerRefreshTag = 100101

extension UIScrollView {
    func addHeader(view:BQRefreshHeaderView) {
        view.tag = headerRefreshTag
        self.addSubview(view)
    }
    func header() -> BQRefreshHeaderView? {
        return self.viewWithTag(headerRefreshTag) as? BQRefreshHeaderView
    }
    func addFooter(view:BQRefreshFooterView) {
        view.tag = footerRefreshTag
        self.addSubview(view)
    }
    func footer() -> BQRefreshFooterView? {
        return self.viewWithTag(footerRefreshTag) as? BQRefreshFooterView
    }
}
