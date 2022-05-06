// *******************************************
//  File Name:      APIItem.swift
//  Author:         MrBai
//  Created Date:   2021/7/28 11:36 AM
//
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import UIKit

/// 接口实例
public struct BQAPIItem: BQAPIProtocol {
    /// 路径
    public var url: String
    /// 接口描述
    public let desc: String
    /// 请求方式
    public let method: BQHTTPMethod

    public init(_ urlPath: String, d: String, m: BQHTTPMethod = .get) {
        url = urlPath
        desc = d
        method = m
    }

    public init(_ path: String, m: BQHTTPMethod) {
        self.init(path, d: path, m: m)
    }

    public func joinPath(_ path: String) -> Self {
        return BQAPIItem(url + path, d: desc, m: method)
    }
}

public extension BQAPIProtocol {
    
    func requestCodable<T: Codable>(_ parameters: [String: Any]? = nil, headers: [String: String]? = nil, animation _: Bool = true, completionHandler: @escaping (_ res: Result<T, BQReqError>) -> Void) {
        BQNetWorking.shared.request(self, parameters: parameters, headers: headers, completionHandler: completionHandler)
    }

    @discardableResult
    func request(_ parameters: [String: Any]? = nil, headers: [String: String]? = nil, animation: Bool = true) -> BQRequest {
        let task = BQNetWorking.shared.request(url: BQAPI.domain + url, method: method, parameters: parameters, headers: headers, animation: animation)
        task.desc = desc
        return task
    }
}
