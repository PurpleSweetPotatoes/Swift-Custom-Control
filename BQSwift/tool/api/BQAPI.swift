// *******************************************
//  File Name:      BQAPI.swift       
//  Author:         MrBai
//  Created Date:   2021/6/11 11:20 PM
//    
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************

import UIKit

#if canImport(Alamofire)

import Alamofire

enum BQHTTPMethod {
    case delete, get, patch, post, put
}

typealias BQSuccessClosure = (_ result: Any) -> Void
typealias BQFailedClosure = (_ error: BQReqError) -> Void

protocol BQAPIProtocol {
    var url: String { get}
    var desc: String { get }
    var method: BQHTTPMethod { get }
}

struct BaseRes<T:Codable>: Codable {
    var code: Int = 0
    var msg: String = ""
    var data: T
}

struct BQReqError: Error {
    let code: Int
    let descrption: String
    let itemDesc: String
    init(_ c: Int, d: String, itemD: String) {
        code = c
        descrption = d
        itemDesc = itemD
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
    /// 项目的域名,针对BQAPIItem使用
    static let domain = "http://xxx.xxx.xxx.xxx/api"
    // 超时时间
    static let timeOut: TimeInterval = 20
    /// 网络请求
    static public func request(url: String, method: BQHTTPMethod = .get, parameters: [String: Any]? = nil, headers: [String: String]? = nil, encoding: ParameterEncoding = URLEncoding.default) -> BQRequest {
        return BQNetWorking.shared.request(url: url, method: method, parameters: parameters, headers: headers, encoding: encoding)
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
    
    public func request<T:Codable>(_ item: BQAPIProtocol, parameters: [String: Any]? = nil, headers: [String: String]? = nil, animation: Bool = true,  completionHandler: @escaping (_ res: Result<T, BQReqError>) -> Void) {
        
        let url = BQAPI.domain + item.url
        
        var h: HTTPHeaders?
        if let tempHeaders = headers {
            h = HTTPHeaders(tempHeaders)
        }
        
        if animation {
            ActivityView.show()
        }
        sessionManager.request(url, method: methodWith(item.method), parameters: parameters, encoding: JSONEncoding.default, headers: h).responseDecodable(completionHandler: { (response: AFDataResponse<BaseRes<T>>) in
            if animation {
                ActivityView.hide()
            }
            switch response.result {
            case .success(let result):
                if result.code == 200 {
                    completionHandler(.success(result.data))
                } else {
                    BQHudView.show(result.msg, title: item.desc)
                    completionHandler(.failure(BQReqError(result.code, d: result.msg, itemD: item.desc)))
                }
                break
            case .failure(let error):
                BQHudView.show(error.localizedDescription, title: item.desc)
                completionHandler(.failure(BQReqError(error.responseCode ?? 0, d: error.localizedDescription, itemD: item.desc)))
                break
            }
        });
    }
    
    public func request(url: String, method: BQHTTPMethod = .get, parameters: [String: Any]? = nil, headers: [String: String]? = nil, animation: Bool = true, encoding: ParameterEncoding = URLEncoding.default) -> BQRequest {
        let task = BQRequest()
        
        var h: HTTPHeaders?
        if let tempHeaders = headers {
            h = HTTPHeaders(tempHeaders)
        }
        if animation {
            ActivityView.show()
        }
        task.request = sessionManager.request(url,method: methodWith(method), parameters: parameters, encoding: encoding, headers: h).validate().responseJSON { [weak self] response in
            if animation {
                ActivityView.hide()
            }
            task.handleResponse(response: response)
            if let index = self?.taskQueue.firstIndex(of: task) {
                self?.taskQueue.remove(at: index)
            }
        }
        taskQueue.append(task)
        return task
    }
}

#endif
