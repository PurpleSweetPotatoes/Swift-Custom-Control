//
//  URL+BQExtension.swift
//  Pods
//  
//  Created by Bai, Payne on 2023/5/6.
//  Copyright © 2023 Garmin All rights reserved
//  

import Foundation

extension URL {
    func withQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        return components?.url
    }
}
