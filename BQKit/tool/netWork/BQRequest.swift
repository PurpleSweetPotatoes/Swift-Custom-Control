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
    var result: Any?
    weak var task: URLSessionTask?

    public func url() -> String { return "" }
    public func toDiction() -> [String: Any] {
        let mir = Mirror(reflecting: self)
        var dict = [String: AnyObject]()
        for p in mir.children {
            if p.label == "method" || p.label == "result" || p.label == "task"{
                continue
            }
            dict[p.label!] = (p.value as AnyObject)
        }
        return dict
    }
    public func responseAction(data: Data?, response: URLResponse?, error: Error?) {
        if let data = data {
            do {
                self.result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            } catch let err as NSError {
                print(err.localizedDescription)
            }
        }
        if let error = error {
            print(error.localizedDescription)
        }
    }
    deinit {
        print("request释放")
        if let task = self.task{
            if task.state == .running || task.state == .suspended {
                print("cancel \(task)")
                task.cancel()
            }
            self.task = nil
            print("释放task")
        }
    }
}
