//
//  BQSQLiteModel.swift
//  bookkeeping
//
//  Created by baiqiang on 2022/3/26.
//

import Foundation
 
public enum SQLiteType: String {
    case text = "TEXT"     //字符串、日期
    case inter = "INTEGER" //数字、时间戳
    case float = "REAL"    // 浮点数
    case bool = "BLOB"     // 真假,很少使用
}

public protocol SQLiteModelProtocol: Codable {
    /// 表名
    static var tableName: String { get }
    
    /// 主键
    var id: Int { get set }
    
    /// 建表信息
    static var propertyTypes: [String: SQLiteType] { get }
    
    // MARK: 不用重写
    
    /// 基于建表信息的key排序
    static var propertyNames: [String] { get }
    
    /// 属性名为key，值为value的字典
    var propertyDic: [String: String] { get }
}

public extension SQLiteModelProtocol {
    
    var propertyDic: [String: String] {
        var dic = [String: String]()
        let mirr = Mirror(reflecting: self)
        for child in mirr.children {
            if let lab = child.label {
                dic[lab] = "\(child.value)"
            }
        }
        return dic
    }
    
    static var propertyNames: [String] {
        return propertyTypes.keys.sorted();
    }
    
}
