// *******************************************
//  File Name:      BQRequest.swift
//  Author:         MrBai
//  Created Date:   2019/11/12 4:16 PM
//
//  Copyright © 2019 baiqiang
//  All rights reserved
// *******************************************


/*
 需要导入Alamofire
 */
import UIKit
import Alamofire

public enum RequestMethod: String {
    case get
    case post
    case put
    case delete
}

public protocol BQRequest {
    //自定义实现
    static var hostName: String { get }
    static var urlPath: String { get }
    static func willSendRequest(url: String, params:[String:Any]?, header:[String:String]?)
    static func receiveResponse(data: Data?)
    
    //选择实现
    static var method: RequestMethod { get }
    
    //默认实现
    static func request(_ handle: @escaping (Any?, Error?) -> Void)
    static func request(params:[String: Any]?, _ handle: @escaping (Any?, Error?) -> Void)
    static func request(headers: [String:String]?, _ handle: @escaping (Any?, Error?) -> Void)
    static func request(params:[String: Any]?, headers: [String:String]?, _ handle: @escaping (Any?, Error?) -> Void)
}

public extension BQRequest {
        
    static var method: RequestMethod {
        return .get
    }
    
    static func request(_ handle: @escaping (Any?, Error?) -> Void) {
        self.request(params: nil, headers: nil, handle)
    }
    
    static func request(params:[String: Any]?, _ handle: @escaping (Any?, Error?) -> Void) {
        self.request(params: params, headers: nil, handle)
    }
    
    static func request(headers: [String:String]?, _ handle: @escaping (Any?, Error?) -> Void) {
        self.request(params: nil, headers: headers, handle)
    }
    
    static func request(params:[String: Any]?, headers: [String:String]?, _ handle: @escaping (Any?, Error?) -> Void) {
        let url = hostName + urlPath

        var requestType: HTTPMethod
        switch method {
        case .get:
            requestType = .get
        case .post:
            requestType = .post
        case .put:
            requestType = .put
        case .delete:
            requestType = .delete
        }
        
        Self.willSendRequest(url: url, params: params, header: headers)
        
        Alamofire.request(url, method: requestType, parameters: params, headers: headers).response { (response) in
            
            Self.receiveResponse(data: response.data)
            
            if let err = response.error {
                handle(nil,err)
            } else if let data = response.data {
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    handle(result,nil)
                } catch let err {
                    print(err.localizedDescription)
                    handle(nil,err)
                }
                
            }
        }
    }
}
