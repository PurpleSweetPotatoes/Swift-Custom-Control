// *******************************************
//  File Name:      BQUserDefaults.swift
//  Author:         MrBai
//  Created Date:   2022/4/26 22:37
//
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import Foundation

@propertyWrapper
public struct LocalDefaultValue<Value> {
    let userDefault = UserDefaults.standard
    let key: String
    let defaultValue: Value

    public var wrappedValue: Value {
        get {
            userDefault.value(forKey: key) as? Value ?? defaultValue
        }
        set { userDefault.set(newValue, forKey: key) }
    }
}

@propertyWrapper
public struct LocalValue<Value> {
    let userDefault = UserDefaults.standard
    public let key: String

    public init(key: String) {
        self.key = key
    }

    public var wrappedValue: Value? {
        get {
            userDefault.value(forKey: key) as? Value
        }
        set { userDefault.set(newValue, forKey: key) }
    }
}
