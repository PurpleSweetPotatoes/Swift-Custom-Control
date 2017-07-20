//
//  BQAPIManager.swift
//  BQTabBarTest
//
//  Created by MrBai on 2017/7/20.
//  Copyright © 2017年 MrBai. All rights reserved.
//

import UIKit


enum SeverType: Int {
    case localSever = 0
    case testSever
    case onlineSever
}
let sever:SeverType = .testSever

private let base_url:[String] = ["",
                                 "",
                                 ""]

let baseUrl = base_url[sever.rawValue]

class BQAPIManager: NSObject {
    
    @discardableResult
    public class func sendRequest(request: BQRequest, completionHandler:@escaping () -> ()) -> URLSessionDataTask? {
        return BQNetWork.sendRequest(urlstr: baseUrl + request.url(), parameter: request.toDiction(), method: request.method, time: 10, headers: nil) { (data, response, error) in
            request.responseAction(data: data, response: response, error: error)
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
}


