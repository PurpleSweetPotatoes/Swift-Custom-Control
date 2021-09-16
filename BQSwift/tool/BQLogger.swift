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

public enum BQLogger {
    private static var crashHandler: ((NSException) -> Void?)?
    private static var preCrashHandler: ((NSException) -> Void?)?

    fileprivate static var canLog = true
    fileprivate static var canSave = false
    private static let dateFormat = DateFormatter()

    /// 开启本地日志记录
    /// - Parameter handle: 文件超过阈值时回调
    public static func cleanLogInfoHandle(handle _: (String) -> Void) {}

    /// 开启crash日志
    /// - Parameter handle: 获取到crash日志后回调
    public static func loadCrashInfo(handle: (String) -> Void) {
        BQLogger.preCrashHandler = NSGetUncaughtExceptionHandler()
        let crashPath = crashFilePath()

        if let crashInfo = try? String(contentsOfFile: crashPath), crashInfo.count > 0 {
            handle(crashInfo)
            try? "".write(toFile: crashPath, atomically: true, encoding: .utf8)
        }

        NSSetUncaughtExceptionHandler { exception in
            let disPlayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName")!
            let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
            let callStack = exception.callStackSymbols.joined(separator: "\n")

            let content = "**********   \(BQLogger.currentTime())    **********\ndisName:\(disPlayName)\t version:\(appVersion)\t system:\(UIDevice.current.systemVersion)\n\(exception.name) \(exception.reason ?? "")\ncallStackSymbols:\n\(callStack)"
            try? content.write(toFile: BQLogger.crashFilePath(), atomically: true, encoding: .utf8)

            if let preHand = BQLogger.preCrashHandler {
                preHand(exception)
            }
        }
    }

    // MARK: - private

    fileprivate static func currentTime() -> String {
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        return dateFormat.string(from: Date())
    }

    private static func crashFilePath() -> String {
        let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return document.appending("/BQCrashInfo.log")
    }

    private static func logFilePath() -> String {
        let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
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
                if type.count > 0 {
                    output = "\(type) \(output)"
                }
                print(output)
            }
        }
    }
}
