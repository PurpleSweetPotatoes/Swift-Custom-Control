//
//  BQDbHelper.swift
//  bookkeeping
//
//  Created by baiqiang on 2022/3/26.
//

import SQLite
import UIKit

public class BQDbHelper: NSObject {
    public static let share = BQDbHelper()
    
    private var sqlDb: Connection?
    
    override private init() {}
    
//    MARK: Public
    
    public func createDB(dbName: String = "BQDb.sqlite3") {
        let dbPath = String.documentPath.appending("/\(dbName)")
        do {
            sqlDb = try Connection(dbPath)
        } catch let err {
            assertionFailure(err.localizedDescription)
        }
        BQLogger.debug("初始化数据库成功")
    }
    
    @discardableResult
    public func createTable(_ cls: SQLiteModelProtocol.Type) -> Bool {
        guard let db = sqlDb else { return false }
        let tableName = cls.tableName
        
        var sql = "CREATE TABLE IF NOT EXISTS \(tableName) (id INTEGER PRIMARY KEY AUTOINCREMENT"
        let infos = cls.propertyTypes
        let keys = cls.propertyNames
        for key in keys {
            if let type = infos[key] {
                sql.append(",\(key) \(type.rawValue)")
            }
        }
        sql.append(")")
        do {
            try db.execute(sql)
            BQLogger.debug("sql: \(sql) \n 表 \(tableName) 创建成功!")
            return true
        } catch let err {
            BQLogger.debug("建表 \(tableName) 失败: \(err.localizedDescription)")
            return false
        }
    }
    
    @discardableResult
    public func dorpTable(_ cls: SQLiteModelProtocol.Type) -> Bool {
        guard let db = sqlDb else { return false }
        
        let sql = "DROP TABLE \(cls.tableName)"
        do {
            try db.execute(sql)
            BQLogger.debug("表 \(cls.tableName) 删除成功!")
            return true
        } catch let err {
            BQLogger.debug("删表 \(cls.tableName) 失败! \(err.localizedDescription)")
            return false
        }
    }
    
    /// 插入单个
    @discardableResult
    public func save<T: SQLiteModelProtocol>(_ model: T) -> Bool {
        guard let db = sqlDb else { return false }
        
        let infos = T.propertyTypes
        let keys = T.propertyNames
        var values = [String]()
        let dic = model.propertyDic
        for key in keys {
            if let value = dic[key] {
                values.append(infos[key]! == .text ? "'\(value)'" : value)
            }
        }
        let sql = "INSERT INTO \(type(of: model).tableName) (\(keys.joined(separator: ","))) VALUES (\(values.joined(separator: ",")))"
        do {
            try db.execute(sql)
            BQLogger.debug("插入数据成功")
            return true
        } catch let err {
            BQLogger.debug("插入数据失败 \(err.localizedDescription)")
            return false
        }
    }
    
    /// 修改单个
    @discardableResult
    public func update<T: SQLiteModelProtocol>(_ model: T) -> Bool {
        guard let db = sqlDb else { return false }
        
        let infos = T.propertyTypes
        let dic = model.propertyDic
        var sql = "UPDATE \(type(of: model).tableName) SET"
        var setArr = [String]()
        for (key, type) in infos {
            if let value = dic[key] {
                setArr.append(" \(key) = \(type == .text ? "'\(value)'" : value)")
            }
        }
        sql.append(" \(setArr.joined(separator: ",")) WHERE id = \(model.id)")
        
        do {
            try db.execute(sql)
            BQLogger.debug("插入数据成功")
            return true
        } catch let err {
            BQLogger.debug("插入数据失败 \(err.localizedDescription)")
            return false
        }
    }
    
    /// 删除单个
    @discardableResult
    public func delete(_ model: SQLiteModelProtocol) -> Bool {
        return delete(type(of: model), condition: "id=\(model.id)")
    }
    
    /// 删除多个，不设置条件全部删除
    @discardableResult
    public func delete(_ cls: SQLiteModelProtocol.Type, condition: String = "") -> Bool {
        guard let db = sqlDb else { return false }
        
        let sql = "DELETE FROM \(cls.tableName) WHERE \(condition)"
        do {
            try db.execute(sql)
            BQLogger.debug("删除成功")
        } catch let err {
            BQLogger.debug("删除失败 \(err.localizedDescription)")
        }
        return true
    }
    
    /// 数据查找
    /// - Parameters:
    ///   - cls: 返回模型
    ///   - condition: 查询条件
    @discardableResult
    public func list<T: SQLiteModelProtocol>(_ cls: T.Type, condition: String = "") -> [T]? {
        guard let db = sqlDb else { return nil }
        var sql = "SELECT * FROM \(cls.tableName)"
        
        if condition.count > 0 {
            sql.append(" WHERE \(condition)")
        }

        do {
            let rows = try db.prepare(sql)
            var keys = T.propertyNames
            keys.insert("id", at: 0)
            var list = [[String: Any]]()
            for row in rows {
                var dic = [String: Any]()
                for (index, key) in keys.enumerated() {
                    dic[key] = row[index]
                }
                list.append(dic)
            }
            
            if let arr = Array<T>.decodeJSON(from: list) {
                return arr
            }
            
        } catch let err {
            BQLogger.debug("\(cls.tableName) 查询失败 \(err.localizedDescription)")
        }
        
        return nil
    }
}
