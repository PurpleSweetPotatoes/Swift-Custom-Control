//
//  Bundle+BQExtension.swift
//  Pods
//  
//  Created by Bai, Payne on 2023/11/5.
//  Copyright © 2023 Garmin All rights reserved
//  

import Foundation

extension Bundle {
    private static let moduleName = "BQSwiftKit"
    static var bqSwiftModule: Bundle? {
        guard let url = Bundle.main.url(forResource: "Frameworks/\(moduleName).framework/\(moduleName)", withExtension: "bundle"),
              let bundle = Bundle(url: url) else {
            return nil
        }
        return bundle
    }
}
