//
//  IOCFactory.swift
//  BQSwiftKit
//
//  Created by baiqiang on 2023/5/21.
//

import UIKit

public struct IOCFactory {

    private static var instanceMap: [String : Any] = [:]

    public static func register(instance: Any) {
        let key = "\(type(of: instance))"
        instanceMap[key] = instance
    }

    public static func load<T>() throws -> T {
        let key = "\(T.self)"
        guard let instance = instanceMap[key] as? T else {
            assert(false, "IOC container don't have \(key)")
            throw NSError(domain: "IOCFactory", code: 400)
        }
        return instance
    }
}
