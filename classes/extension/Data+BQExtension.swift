// *******************************************
//  File Name:      Data+BQExtension.swift
//  Author:         MrBai
//  Created Date:   2019/8/15 9:18 AM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************

import Foundation

public extension Data {
    func toDic() -> Any {
        var result: Any = ""
        do {
            result = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
        } catch let err as NSError {
            print(err.localizedDescription)
        }
        return result
    }

    // MARK: - ***** 钥匙串保存 *****

    // if want to use this method should open keychain sharing
    @discardableResult
    func saveKeychain() -> Bool {
        var keychainQuery = type(of: self).getkeychain()
        SecItemDelete(keychainQuery as CFDictionary)
        keychainQuery[kSecValueData as String] = self as AnyObject
        let statu = SecItemAdd(keychainQuery as CFDictionary, nil)
        return statu == noErr
    }

    @discardableResult
    static func deleteKeyChain() -> Bool {
        let keychainQuery = getkeychain()
        let statu = SecItemDelete(keychainQuery as CFDictionary)
        return statu == noErr
    }

    static func loadKeychain() -> Data? {
        var keychainQuery = getkeychain()
        keychainQuery[kSecReturnData as String] = kCFBooleanTrue as AnyObject
        keychainQuery[kSecMatchLimit as String] = kSecMatchLimitOne as AnyObject
        var result: AnyObject?
        let statu = SecItemCopyMatching(keychainQuery as CFDictionary, &result)
//        let statu = withUnsafeMutablePointer(to: &result) {
//            SecItemCopyMatching(keychainQuery as CFDictionary, UnsafeMutablePointer($0))
//        }
        if statu == noErr {
            return result as? Data
        }
        return nil
    }

    var hexStr: String {
        return map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - ***** private Method *****

    private static func getkeychain() -> [String: AnyObject] {
        let serveice = Bundle.main.bundleIdentifier!
        return Dictionary(dictionaryLiteral: (kSecClass as String, kSecClassGenericPassword as AnyObject), (kSecAttrService as String, serveice as AnyObject), (kSecAttrAccount as String, serveice as AnyObject), (kSecAttrAccessible as String, kSecAttrAccessibleAfterFirstUnlock as AnyObject))
    }
}
