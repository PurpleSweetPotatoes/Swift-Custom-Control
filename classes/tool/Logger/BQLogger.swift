// *******************************************
//  File Name:      BQLogger.swift
//  Author:         MrBai
//  Created Date:   2019/10/31 10:45 AM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

public typealias CrashBlock = (NSException) -> Void?

// MARK: - BQLogger

public enum BQLogger {
    
    static private let configInfo = BQLoggerConfig()
    
    static public func config() -> BQLoggerConfig {
        return configInfo
    }

    /// 开启本地日志记录
    /// - Parameter handle: 文件超过阈值时回调(传回文件路径)回调后文件将被删除重建
    static public func limitHandle(_ handle: @escaping (String) -> Void) {
        fileBlock = handle
    }
    
    static func loadLogger() -> String? {
        return try? String(contentsOfFile: logFilePath)
    }
    
    public static func clearLogger() {
        fileHandle?.closeFile()
        fileHandle = nil
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: logFilePath))
    }

    /// 开启crash日志，无回调存放于本地使用
    /// loadCrashInfo获取
    /// - Parameter handle: 获取到crash日志后回调
    public static func startCrashIntercept(_ handle: CrashBlock? = nil) {
        BQLogger.preCrashHandler = NSGetUncaughtExceptionHandler()
        crashHandler = handle
        NSSetUncaughtExceptionHandler { exception in
            if let block = BQLogger.crashHandler {
                block(exception)
            } else {
                let callStack = exception.callStackSymbols.joined(separator: "\n")
                let content = "**********   \(BQLogger.currentTime())    **********\ndisName:\(AppInfo.name)\t version:\(AppInfo.version)\t system:\(UIDevice.current.systemVersion)\n\(exception.name) \(exception.reason ?? "")\ncallStackSymbols:\n\(callStack)"
                try? content.write(toFile: BQLogger.crashFilePath(), atomically: true, encoding: .utf8)
            }

            if let preHand = BQLogger.preCrashHandler {
                preHand(exception)
            }
        }
    }

    public static func loadCrashInfo(clean: Bool = false) -> String? {
        let outStr = try? String(contentsOfFile: crashFilePath())
        if clean {
            try? "".write(toFile: BQLogger.crashFilePath(), atomically: true, encoding: .utf8)
        }
        if let str = outStr, str.isEmpty {
            return nil
        }
        return outStr
    }

    public static func showInfo(_ info: String) {
        let sv = UIView(frame: UIScreen.main.bounds)
        sv.backgroundColor = UIColor(white: 0, alpha: 0.7)
        UIApplication.shared.keyWindow?.addSubview(sv)

        let bv = UILabel(frame: CGRect(x: 0, y: sv.sizeH - 50, width: sv.sizeW, height: 50), font: .systemFont(ofSize: 16), text: "返回", textColor: .white, alignment: .center)
        bv.isUserInteractionEnabled = true
        bv.addTapGes { v in
            v.superview?.removeFromSuperview()
        }
        sv.addSubview(bv)

        let iv = UITextView(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: sv.sizeW, height: sv.sizeH - bv.sizeH - AppInfo.statusHeight))
        iv.font = .systemFont(ofSize: 14)
        iv.backgroundColor = .clear
        iv.textColor = bv.textColor
        iv.isEditable = false
        iv.text = info
        sv.addSubview(iv)
    }

    // MARK: Fileprivate

    fileprivate static var canLog = true
    fileprivate static var fileHandle: FileHandle?
    fileprivate static var fileBlock: StrBlock?
    fileprivate static var cache = Array<String>()
    
    /// 缓存数组长度
    fileprivate static var cacheLength = 10
    fileprivate static func currentTime() -> String {
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormat.string(from: Date())
    }

    // MARK: Private

    private static var crashHandler: CrashBlock?
    private static var preCrashHandler: CrashBlock?

    private static let dateFormat = DateFormatter()

    private static func crashFilePath() -> String {
        let document = String.documentPath
        return document.appending("/BQCrashInfo.log")
    }

    private static var logFilePath : String {
        String.documentPath.appending("/BQLogInfo.log")
    }
}

public extension BQLogger {

    static func debug<T>(_ messsage: T, file: String = #file, funcName: String = #function, lineNum: Int = #line) {
        printInfo(type: .debug, messsage: messsage, file: file, funcName: funcName, lineNum: lineNum)
    }
    
    static func info<T>(_ messsage: T, file: String = #file, funcName: String = #function, lineNum: Int = #line) {
        printInfo(type: .info, messsage: messsage, file: file, funcName: funcName, lineNum: lineNum)
    }
    
    static func log<T>(_ messsage: T, file: String = #file, funcName: String = #function, lineNum: Int = #line) {
        printInfo(type: .defualt, messsage: messsage, file: file, funcName: funcName, lineNum: lineNum)
    }
    
    static func error<T>(_ messsage: T, file: String = #file, funcName: String = #function, lineNum: Int = #line) {
        printInfo(type: .error, messsage: messsage, file: file, funcName: funcName, lineNum: lineNum)
    }

    private static func printInfo<T>(type: BQLogType, messsage: T, file: String = #filePath, funcName: String = #function, lineNum: Int = #line) {
        
        let output = "\(type.colorStr)\(BQLogger.currentTime()) [\(file.lastPathComponentName):\(lineNum)] \(funcName) >>> \(messsage)\n"
        
        if configInfo.canLog(type: type) {
            print(output, terminator:"")
        }
        
        // 保存
        if configInfo.canSave(type: type) {
            configInfo.loggerQueue.async {
                saveInfo(info: output, filePath: logFilePath)
            }
        }
    }

    private static func saveInfo(info: String, filePath: String) {
        
        if !FileManager.default.fileExists(atPath: filePath) { // 不存在,创建文件
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
        
        if fileHandle == nil {
            fileHandle = FileHandle(forUpdatingAtPath: filePath)
            fileHandle?.seekToEndOfFile()
        }
        
        if let file = fileHandle, let data = info.data(using: .utf8) {
            file.write(data)
            checkFileLimit(filePath: filePath)
        }
    }

    private static func checkFileLimit(filePath: String) {
        if let fileInfo = try? FileManager.default.attributesOfItem(atPath: filePath) {
            func callLimitBlock() {
                if let block = fileBlock {
                    block(filePath)
                }
                clearLogger()
            }
            
            if let size = fileInfo[FileAttributeKey.size] as? NSNumber, size.doubleValue >= configInfo.maxSize {
                callLimitBlock()
            } else if let date = fileInfo[FileAttributeKey.creationDate] as? Date, -date.timeIntervalSinceNow >= configInfo.saveTime {
                callLimitBlock()
            }
        }
    }
}
