// *******************************************
//  File Name:      BQAPI.swift       
//  Author:         MrBai
//  Created Date:   2021/6/11 11:20 PM
//    
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import UIKit
import Alamofire

enum BQHTTPMethod {
    case delete, get, patch, post, put
}

typealias BQSuccessClosure = (_ result: Any) -> Void
typealias BQFailedClosure = (_ error: String, _ desc: String) -> Void

protocol BQAPIProtocol {
    var url: String { get}
    var desc: String { get }
    var method: BQHTTPMethod { get }
}

extension BQAPIProtocol {
    /// 开始网络请求
    /// - Parameters:
    ///   - parameters: 参数
    ///   - headers: 头部参数
    /// - Returns: 网络请求对象
    @discardableResult
    func request(_ parameters: [String: Any]? = nil, headers: [String: String]? = nil) -> BQRequest {
        let task = BQNetWorking.shared.request(self, parameters: parameters, headers: headers)
        task.desc = desc
        return task
    }
}

/**
接口实例管理类
 - 使用方式1:
```
let url = "https://api.xxx.com/home/banner_list"
BQAPI.request(url: url).success { result in
    print("类型:\(type(of: result)) 结果:\(result)")
}.failed { errStr, desc in
    print("接口描述: \(desc), 错误信息: \(errStr)")
}
```
 - 使用方式2:
```
//定义模块接口
extension BQAPI {
  struct Home {
      static let bannerList = APIItem("home/banner_list", d: "获取上传认证信息", m: .get)
  }
}
//调用接口
BQAPI.Home.bannerList.request().success { result in
    print("类型:\(type(of: result)) 结果:\(result)")
}.failed { errStr, desc in
    print("接口描述: \(desc), 错误信息: \(errStr)")
}
```
 */
struct BQAPI {
    /// 项目的域名
    static let domain = "http://js.exc360.com/"
    // 超时时间
    static let timeOut: TimeInterval = 20
    /// 网络请求
    static public func request(url: String, method: BQHTTPMethod = .get, parameters: [String: Any]? = nil, headers: [String: String]? = nil, encoding: ParameterEncoding = URLEncoding.default) -> BQRequest {
        return BQNetWorking.shared.request(url: url, method: method, parameters: parameters, headers: headers, encoding: encoding)
    }
}

/// 接口实例
struct APIItem: BQAPIProtocol {
    /// 路径
    let url: String
    /// 接口描述
    let desc: String
    /// 请求方式
    let method: BQHTTPMethod

    init(_ urlPath: String, d: String, m: BQHTTPMethod = .get) {
        url = urlPath
        desc = d
        method = m
    }

    init(_ path: String, m: BQHTTPMethod) {
        self.init(path, d: path, m: m)
    }

}

final class BQNetWorking {
    public static let shared = BQNetWorking()
    private var sessionManager: Alamofire.Session!
    private(set) var taskQueue = [BQRequest]()
    
    private init() {
        let config = URLSessionConfiguration.af.default
        config.timeoutIntervalForRequest = BQAPI.timeOut
        config.timeoutIntervalForResource = BQAPI.timeOut
        sessionManager = Alamofire.Session(configuration: config)
    }
    
    private func methodWith(_ m: BQHTTPMethod) -> Alamofire.HTTPMethod {
        // case delete, get, patch, post, put
        switch m {
        case .delete: return .delete
        case .get: return .get
        case .patch: return .patch
        case .post: return .post
        case .put: return .put
        }
    }
    
    public func request(_ item: BQAPIProtocol, parameters: [String: Any]? = nil, headers: [String: String]? = nil, encoding: ParameterEncoding = URLEncoding.default) -> BQRequest {
        return request(url: BQAPI.domain + item.url, method: item.method, parameters: parameters, headers: headers, encoding: encoding)
    }
    
    public func request(url: String, method: BQHTTPMethod = .get, parameters: [String: Any]? = nil, headers: [String: String]? = nil, encoding: ParameterEncoding = URLEncoding.default) -> BQRequest {
        let task = BQRequest()
        
        var h: HTTPHeaders?
        if let tempHeaders = headers {
            h = HTTPHeaders(tempHeaders)
        }

        task.request = sessionManager.request(url,
                                              method: methodWith(method),
                                              parameters: parameters,
                                              encoding: encoding,
                                              headers: h).validate().responseJSON { [weak self] response in
            task.handleResponse(response: response)

            if let index = self?.taskQueue.firstIndex(of: task) {
                self?.taskQueue.remove(at: index)
            }
        }
        taskQueue.append(task)
        return task
    }
}


/**
 网络请求对象，使用点语法配置成功和失败回调
 */
final class BQRequest {
    
    var request: Alamofire.Request?
    var desc: String = ""
    
    private var successHandler: BQSuccessClosure?
    private var failedHandler: BQFailedClosure?

    // MARK: - Handler
    func handleResponse(response: AFDataResponse<Any>) {
        switch response.result {
        case .failure(let error):
            if let closure = failedHandler {
                closure(error.localizedDescription, desc)
            }
        case .success(let result):
            if let closure = successHandler {
                closure(result)
            }
        }
    
        successHandler = nil
        failedHandler = nil
    }

    @discardableResult
    public func success(_ closure: @escaping BQSuccessClosure) -> Self {
        successHandler = closure
        return self
    }

    @discardableResult
    public func failed(_ closure: @escaping BQFailedClosure) -> Self {
        failedHandler = closure
        return self
    }
    
    func cancel() {
        request?.cancel()
    }
}

extension BQRequest: Equatable {
    static func == (lhs: BQRequest, rhs: BQRequest) -> Bool {
        return lhs.request?.id == rhs.request?.id
    }
}
