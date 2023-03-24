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
        var keychainQuery = type(of: self).getKeyChain()
        SecItemDelete(keychainQuery as CFDictionary)
        keychainQuery[kSecValueData as String] = self as AnyObject
        let status = SecItemAdd(keychainQuery as CFDictionary, nil)
        return status == noErr
    }

    @discardableResult
    static func deleteKeyChain() -> Bool {
        let keychainQuery = getKeyChain()
        let status = SecItemDelete(keychainQuery as CFDictionary)
        return status == noErr
    }

    static func loadKeychain() -> Data? {
        var keychainQuery = getKeyChain()
        keychainQuery[kSecReturnData as String] = kCFBooleanTrue as AnyObject
        keychainQuery[kSecMatchLimit as String] = kSecMatchLimitOne as AnyObject
        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &result)
        if status == noErr {
            return result as? Data
        }
        return nil
    }

    var hexStr: String {
        return map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - ***** private Method *****

    private static func getKeyChain() -> [String: AnyObject] {
        let service = Bundle.main.bundleIdentifier!
        return Dictionary(dictionaryLiteral: (kSecClass as String, kSecClassGenericPassword as AnyObject), (kSecAttrService as String, service as AnyObject), (kSecAttrAccount as String, service as AnyObject), (kSecAttrAccessible as String, kSecAttrAccessibleAfterFirstUnlock as AnyObject))
    }
}
