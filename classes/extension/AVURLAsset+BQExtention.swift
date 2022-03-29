// *******************************************
//  File Name:      AVURLAsset+BQExtention.swift       
//  Author:         MrBai
//  Created Date:   2022/3/2 2:04 PM
//    
//  Copyright © 2022 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import AVFoundation

extension AVURLAsset {
    
    static func load(forResource name: String?, ofType ext: String?) -> AVURLAsset? {
        if let path = Bundle.main.path(forResource: name, ofType: ext) {
            return AVURLAsset(url: URL(fileURLWithPath: path))
        }
        return nil
    }
}
