// *******************************************
//  File Name:      BQImageHelper.swift       
//  Author:         MrBai
//  Created Date:   2021/7/31 10:11 AM
//    
//  Copyright © 2021 ___ORGANIZATIONNAME___
//  All rights reserved
// *******************************************
    

import UIKit

#if canImport(Kingfisher)
import Kingfisher

extension UIImageView {
    func kfImage(_ url: String, holderImg: UIImage? = nil, completeHandler: ((Result<UIImage, BQError>) -> Void)? = nil) {
        kf.setImage(with: URL(string: url), placeholder: holderImg) { res in
            if let handle = completeHandler {
                switch res {
                case .success(let result):
                    handle(.success(result.image))
                    break
                case .failure(let err):
                    handle(.failure(BQError(0,err.localizedDescription)))
                    break
                }
            }
        }
    }
    
    static func prefetchLoadImgUrl(urls: [String]) {
        for url in urls {
            if let res = URL(string: url) {
                KingfisherManager.shared.retrieveImage(with: res, completionHandler: nil)
            }
        }
    }
    
    static func cacheSize() {
        ImageCache.default.calculateDiskStorageSize { res in
            switch res {
            case .success(let re):
                BQLogger.log(re.toDiskSize())
            break
            case .failure(let err):
            BQLogger.log(err)
            break
            }
        }
    }
    
    func hasImageCache(_ url: String) -> Bool {
        return ImageCache.default.isCached(forKey: url)
    }
}

#endif
