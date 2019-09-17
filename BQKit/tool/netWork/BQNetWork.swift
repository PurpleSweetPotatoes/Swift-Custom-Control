//
//  BQNetWork.swift
//  BQTabBarTest
//
//  Created by MrBai on 2017/7/20.
//  Copyright © 2017年 MrBai. All rights reserved.
//

import UIKit

public enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
}

struct BQNetWork {
    
    public static func sendRequest(urlstr:String, parameter:[String:Any]? = nil, method: HTTPMethod = .post, time:TimeInterval = 10,headers:[String:String]? = nil, completionHandler:@escaping (Data?, URLResponse?, Error?) -> Void ) -> URLSessionDataTask? {
        if let url = URL(string: urlstr) {
            print("url: \(url) \nparameter: \(String(describing: parameter))")
            var request = encode(url: url, method: method, parameters: parameter,headers:headers)
            request.timeoutInterval = time
            let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
            task.resume()
            return task
        }
        return nil
    }
    
    ///    Use Method
    ///    BQNetWork.uploadImag(bqImgData: { (imgData) in
    ///    imgData.append(data, withName: "img", fileName: "image.jpg", mimeType: "image/jpeg")
    ///    }, to: url, completionHandler: { (result, error) in
    ///    if let err = error {
    ///    print(err.localizedDescription)
    ///    }else {
    ///    print(result)
    ///    }
    ///    })
    public static func uploadImag(bqImgData: @escaping (BQImgData) -> Void,to url:String, method: HTTPMethod = .post, headers:[String: String]? = nil, completionHandler:@escaping (Any?, Error?) -> Void) {
        if let url = URL(string: url) {
            print("upload url: \(url))")
            DispatchQueue.global(qos: .utility).async {
                let formData = BQImgData()
                bqImgData(formData)
                let data = try? formData.encode()
                var request = encode(url: url, method: method, parameters: nil,headers:headers)
                request.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
                let task = URLSession.shared.uploadTask(with: request, from: data, completionHandler: { (data, response, error) in
                    if let error = error {
                        completionHandler(nil,error)
                    }
                    if let data = data {
                        do {
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            completionHandler(result,nil)
                        } catch let err as NSError {
                            completionHandler(nil,err)
                        }
                    }
                })
                task.resume()
            }
        }
    }
    
    //MARK: ---- private Method
    private static func encode(url:URL,method:HTTPMethod,parameters:[String:Any]?, headers:[String: String]?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let head = headers {
            for (headerField, headerValue) in head {
                request.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
        
        guard let parameters = parameters else { return request }

        if method == .get {
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
                urlComponents.percentEncodedQuery = percentEncodedQuery
                request.url = urlComponents.url
            }
        } else {
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            }
            request.httpBody = query(parameters).data(using: .utf8, allowLossyConversion: false)
        }
        
        return request
    }
    
    private static func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    private static func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape((bool ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        return components
    }
    
    private static func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }
}

extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}
