// *******************************************
//  File Name:      BQLogger.swift
//  Author:         MrBai
//  Created Date:   2019/10/31 10:45 AM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import UIKit

private let LoggerQueue = DispatchQueue(label: "com.bq.Logger.queue")

typealias CrashBlock = (NSException) -> Void?

// MARK: - BQLogger

public enum BQLogger {
    // MARK: Internal

    /// 开启本地日志记录
    /// - Parameter handle: 文件超过阈值时回调
    static func cleanLogInfoHandle(handle _: (String) -> Void) {}

    /// 开启crash日志，无回调存放于本地使用
    /// loadCrashInfo获取
    /// - Parameter handle: 获取到crash日志后回调
    static func startCrashIntercept(_ handle: CrashBlock? = nil) {
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
    
    static func loadCrashInfo(clean: Bool = false) -> String? {
        let outStr = try? String(contentsOfFile: crashFilePath())
        if clean {
            try? "".write(toFile: BQLogger.crashFilePath(), atomically: true, encoding: .utf8)
        }
        if let str = outStr, str.count == 0 {
            return nil
        }
        return outStr
    }
    
    static func showInfo(_ info: String) {
        
        let sv = UIView(frame: UIScreen.main.bounds)
        sv.backgroundColor = UIColor(white: 0, alpha: 0.7)
        UIApplication.shared.keyWindow?.addSubview(sv)
        
        let bv = UILabel(frame: CGRect(x: 0, y: sv.sizeH - 50, width: sv.sizeW, height: 50), font: .systemFont(ofSize: 16), text: "返回", textColor: .white, alignment: .center)
        bv.isUserInteractionEnabled = true
        bv.addTapGes { v in
            v.superview?.removeFromSuperview()
        }
        sv.addSubview(bv)
        
        let iv = UITextView.init(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: sv.sizeW, height: sv.sizeH - bv.sizeH - AppInfo.statusHeight))
        iv.font = .systemFont(ofSize: 14)
        iv.backgroundColor = .clear
        iv.textColor = bv.textColor
        iv.isEditable = false
        iv.text = info
        sv.addSubview(iv)
    }

    // MARK: Fileprivate

    fileprivate static var canLog = true
    fileprivate static var canSave = false

    fileprivate static func currentTime() -> String {
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        return dateFormat.string(from: Date())
    }

    // MARK: Private

    private static var crashHandler: CrashBlock?
    private static var preCrashHandler: CrashBlock?

    private static let dateFormat = DateFormatter()

    private static func crashFilePath() -> String {
        let document = NSDocumentPath()
        return document.appending("/BQCrashInfo.log")
    }

    private static func logFilePath() -> String {
        let document = NSDocumentPath()
        return document.appending("/BQlogInfo.log")
    }
}

public extension BQLogger {
    static func log<T>(_ messsage: T, file: String = #file, funcName: String = #function, lineNum: Int = #line) {
        printInfo(type: "", messsage: messsage, file: file, funcName: funcName, lineNum: lineNum)
    }

    static func waring<T>(_ messsage: T, file: String = #file, funcName: String = #function, lineNum: Int = #line) {
        printInfo(type: "⚠️ 警告:", messsage: messsage, file: file, funcName: funcName, lineNum: lineNum)
    }

    static func error<T>(_ messsage: T, file: String = #file, funcName: String = #function, lineNum: Int = #line) {
        printInfo(type: "❌ 错误:", messsage: messsage, file: file, funcName: funcName, lineNum: lineNum)
    }

    private static func printInfo<T>(type: String, messsage: T, file: String = #file, funcName: String = #function, lineNum: Int = #line) {
        if canLog {
            LoggerQueue.async {
                let fileName = String(file.split(separator: "/").last!).split(separator: ".").first!
                var output = "\(BQLogger.currentTime()) \(funcName) at \(fileName) \(lineNum) line: \(messsage)"
                if !type.isEmpty {
                    output = "\(type) \(output)"
                }
                print(output)
            }
        }
    }
}
