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
struct LocalDefaultValue<Value> {
    let userDefault = UserDefaults.standard
    let key: String
    let defaultValue: Value

    var wrappedValue: Value {
        get {
            userDefault.value(forKey: key) as? Value ?? defaultValue
        }
        set { userDefault.set(newValue, forKey: key) }
    }
}

@propertyWrapper
struct LocalValue<Value> {
    let userDefault = UserDefaults.standard
    let key: String

    var wrappedValue: Value? {
        get {
            userDefault.value(forKey: key) as? Value
        }
        set { userDefault.set(newValue, forKey: key) }
    }
}
