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
struct LocalValue<Value> {
    let userDefault = UserDefaults.standard
    let key: String
    let defaultValue: Value?

    var wrappedValue: Value? {
        get {
            userDefault.value(forKey: key) as? Value ?? defaultValue
        }
        set {
            userDefault.set(newValue, forKey: key)
        }
    }
    
}

public struct BQUserDefaults {
    public static let share = BQUserDefaults()
    let user = UserDefaults.standard

    private init() {}

    public func set<T>(_ value: T, key: LocalKey<T>) {
        user.set(value, forKey: key.rawValue)
    }

    public func get<T>(_ key: LocalKey<T>) -> T? {
        return user.object(forKey: key.rawValue) as? T
    }
}
