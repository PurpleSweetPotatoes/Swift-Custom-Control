// *******************************************
//  File Name:      BQError.swift
//  Author:         MrBai
//  Created Date:   2021/7/31 10:47 AM
//
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import Foundation

public struct BQError: Error {
    public let desc: String
    public let code: Int

    public init(_ codeNum: Int, _ reason: String) {
        code = codeNum
        desc = reason
    }

    public var errorDescription: String? {
        return desc
    }
}
