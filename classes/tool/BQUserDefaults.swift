// *******************************************
//  File Name:      BQUserDefaults.swift
//  Author:         MrBai
//  Created Date:   2022/4/26 22:37
//
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import Foundation

public struct LocalKey<T> {
    var rawValue: String
    init(_ key: String) {
        rawValue = "BQUserDefaults_\(key)"
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
