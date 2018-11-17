//
//  UITableView+extension.swift
//  swift4.2Demo
//
//  Created by baiqiang on 2018/10/6.
//  Copyright © 2018年 baiqiang. All rights reserved.
//

import UIKit

typealias TableViewProtocol = UITableViewDelegate & UITableViewDataSource

protocol EmptyViewProtocol: NSObjectProtocol {
    
    ///用以判断是会否显示空视图
    var showEmtpy: Bool {get}
    
    ///配置空数据提示图用于展示
    func configEmptyView() -> UIView?
}

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
    
    /// register cell by cellClass
    open func registerCell(cellClass: AnyClass) {
        
        let identifier = cellClass.description().components(separatedBy: ".").last!
        
        if identifier != "UITableViewCell" {
            self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        } else {
            self.register(cellClass, forCellReuseIdentifier: identifier)
        }
    }
    
    /// get cell by dequeueReusableCell must register use nib
    open func loadCell(cellClass: AnyClass, indexPath: IndexPath) -> UITableViewCell {
        let identifier = cellClass.description().components(separatedBy: ".").last!
        return self.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
    
    func setEmtpyViewDelegate(target: EmptyViewProtocol) {
        self.emptyDelegate = target
        DispatchQueue.once(#function) {
            BQTool.exchangeMethod(cls: self.classForCoder, targetSel: #selector(self.layoutSubviews), newSel: #selector(self.re_layoutSubviews))
        }
    }
    
    @objc func re_layoutSubviews() {
        self.re_layoutSubviews()
        
        if self.emptyDelegate!.showEmtpy {
            
            guard let view = self.emptyDelegate?.configEmptyView() else {
                return;
            }
            
            if view == self.emptyDisView {
                return
            }
            
            if let subView = self.emptyDisView {
                subView.removeFromSuperview()
            }
            
            self.addSubview(view)
            self.emptyDisView = view
            
        } else {
            
            guard let view = self.emptyDisView else {
                return;
            }
            
            view.removeFromSuperview()
        }
    }
    
    //MARK:- ***** Associated Object *****
    private struct AssociatedKeys {
        static var kemptyViewDelegate = "tableView_emptyViewDelegate"
        static var kemptyDisView = "tableView_emptyDisView"
    }
    
    private var emptyDisView: UIView? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.kemptyDisView) as? UIView)
        }
        set (newValue){
            objc_setAssociatedObject(self, &AssociatedKeys.kemptyDisView, newValue!, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private var emptyDelegate: EmptyViewProtocol? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.kemptyViewDelegate) as? EmptyViewProtocol)
        }
        set (newValue){
            objc_setAssociatedObject(self, &AssociatedKeys.kemptyViewDelegate, newValue!, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
}

extension EmptyViewProtocol {
    func configEmptyView() -> UIView? {
        return nil
    }
}
