//
//  Data+extension.swift
//  swift4.2Demo
//
//  Created by baiqiang on 2018/10/6.
//  Copyright © 2018年 baiqiang. All rights reserved.
//

import Foundation

extension Data {
    //MARK:- ***** 钥匙串保存 *****
    //if want to use this method should open keychain sharing
    @discardableResult
    func saveKeychain(data:Data) -> Bool {
        var keychainQuery = type(of: self).getkeychain()
        SecItemDelete(keychainQuery as CFDictionary)
        keychainQuery[kSecValueData as String] = data as AnyObject?
        let statu = SecItemAdd(keychainQuery as CFDictionary, nil)
        return statu == noErr
    }
    
    @discardableResult
    static func deleteKeyChain() -> Bool {
        let keychainQuery = self.getkeychain()
        let statu = SecItemDelete(keychainQuery as CFDictionary)
        return statu == noErr
    }
    
    static func loadKeychain() -> Data? {
        var keychainQuery = self.getkeychain()
        keychainQuery[kSecReturnData as String] = kCFBooleanTrue as AnyObject
        keychainQuery[kSecMatchLimit as String] = kSecMatchLimitOne as AnyObject
        var result: AnyObject?
        let statu = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(keychainQuery as CFDictionary, UnsafeMutablePointer($0))
        }
        if statu == noErr {
            return result as? Data
        }
        return nil
    }
    
    //MARK:- ***** private Method *****
    private static func getkeychain() -> Dictionary<String,AnyObject> {
        let serveice = Bundle.main.bundleIdentifier!
        return Dictionary(dictionaryLiteral: (kSecClass as String,kSecClassGenericPassword as AnyObject),(kSecAttrService as String ,serveice as AnyObject),(kSecAttrAccount as String,serveice as AnyObject),(kSecAttrAccessible as String,kSecAttrAccessibleAfterFirstUnlock as AnyObject))
    }
    
}
