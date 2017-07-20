//
//  BQRequest.swift
//  BQTabBarTest
//
//  Created by MrBai on 2017/7/20.
//  Copyright © 2017年 MrBai. All rights reserved.
//

import UIKit

class BQRequest: NSObject {
    
    var method: HTTPMethod = .post
    
    /// loadResult from network
    var result: Any?

    /// to set API url,subclass must override
    public func url() -> String { return "" }
    
    public func toDiction() -> [String: Any] {
        let mir = Mirror(reflecting: self)
        var dict = [String: AnyObject]()
        for p in mir.children {
            if p.label == "method" || p.label == "result" {
                continue
            }
            dict[p.label!] = (p.value as AnyObject)
        }
        return dict
    }
    
    
    /// base action Response, subclass should use this method, then action self handler
    public func responseAction(data: Data?, response: URLResponse?, error: Error?) {
        if let data = data {
            self.result = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
        }
        if let error = error {
            print(error.localizedDescription)
        }
    }
}
