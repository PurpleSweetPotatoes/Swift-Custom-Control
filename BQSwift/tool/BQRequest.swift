// *******************************************
//  File Name:      BQAPI.swift
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


public protocol BQAPI {
    //自定义实现
    static var hostName: String { get }
    static var urlPath: String { get }
    static func willSendRequest(url: String, params:[String:Any]?, header: HTTPHeaders?)
    static func receiveResponse(data: Data?)
    
    //选择实现
    static var method: HTTPMethod { get }
    
    //默认实现
    static func request(_ handle: @escaping (Any?, Error?) -> Void)
    static func request(params:[String: Any]?, _ handle: @escaping (Any?, Error?) -> Void)
    static func request(headers: [String:String]?, _ handle: @escaping (Any?, Error?) -> Void)
    static func request(params:[String: Any]?, headers: [String:String]?, _ handle: @escaping (Any?, Error?) -> Void)
}

public extension BQAPI {
        
    static var method: HTTPMethod {
        return .get
    }
    
    static func request(_ handle: @escaping (Any?, Error?) -> Void) {
        self.request(params: nil, headers: nil, handle)
    }
    
    static func request(params:Parameters?, _ handle: @escaping (Any?, Error?) -> Void) {
        self.request(params: params, headers: nil, handle)
    }
    
    static func request(headers: HTTPHeaders?, _ handle: @escaping (Any?, Error?) -> Void) {
        self.request(params: nil, headers: headers, handle)
    }
    
    static func request(params:Parameters?, headers: HTTPHeaders?, _ handle: @escaping (Any?, Error?) -> Void) {
        let url = hostName + urlPath
    
        Self.willSendRequest(url: url, params: params, header: headers)
        
        AF.request(url, method: method, parameters: params, headers: headers).responseJSON(completionHandler: { response in
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
        })
    }
}
