// *******************************************
//  File Name:      BQLogger.swift       
//  Author:         MrBai
//  Created Date:   2019/10/31 10:45 AM
//    
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************
    

import UIKit

public struct BQLogger {
    static private var crashHandler: ((NSException) -> Void?)?
    static private var preCrashHandler: ((NSException) -> Void?)?
    
    static fileprivate var canLog = false
    static fileprivate var canSave = false
    static private let dateFormat = DateFormatter()
    
    public static func start() {
        BQLogger.canLog = true
    }
    
    
    /// 开启本地日志记录
    /// - Parameter handle: 文件超过阈值时回调
    public static func cleanLogInfoHandle(handle: (String) -> Void) {
        
        
    }
    
    /// 开启crash日志
    /// - Parameter handle: 获取到crash日志后回调
    public static func loadCrashInfo(handle: (String) -> Void) {
        BQLogger.canSave = true
        BQLogger.preCrashHandler = NSGetUncaughtExceptionHandler()
        let crashPath = self.crashFilePath()
        
        if let crashInfo = try? String(contentsOfFile: crashPath), crashInfo.count > 0{
            handle(crashInfo)
            try? "".write(toFile: crashPath, atomically: true, encoding: .utf8)
        }
        
        NSSetUncaughtExceptionHandler { (exception) in
            let disPlayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName")!
            let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
            let  callStack = exception.callStackSymbols.joined(separator: "\n");
            
            let content = "**********   \(BQLogger.currentTime())    **********\ndisName:\(disPlayName)\t version:\(appVersion)\t system:\(UIDevice.current.systemVersion)\n\(exception.name) \(exception.reason ?? "")\ncallStackSymbols:\n\(callStack)"
            try? content.write(toFile: BQLogger.crashFilePath(), atomically: true, encoding: .utf8)
            
            if let preHand = BQLogger.preCrashHandler {
                preHand(exception)
            }
        }
    }
    
    // MARK: - private
    fileprivate static func currentTime() -> String {
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
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

public func BQLog<T>(_ messsage : T, file : String = #file, funcName : String = #function, lineNum : Int = #line) {
    if BQLogger.canLog || BQLogger.canSave {
        let fileName = String(file.split(separator: "/").last!).split(separator: ".").first!
        let output = "\(BQLogger.currentTime()) \(funcName) at \(fileName) \(lineNum) line:\n \(messsage)"
        if BQLogger.canLog {
            print(output)
        }
        if BQLogger.canSave {
            
        }
    }
}
