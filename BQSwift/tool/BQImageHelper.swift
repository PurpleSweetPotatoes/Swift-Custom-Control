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
        func kfImage(_ url: String, holderImg: UIImage? = nil, needProgress: Bool = false, completeHandler: ((Result<UIImage, BQError>) -> Void)? = nil) {
            let proVTag = 10843
            if needProgress {
                if let v = viewWithTag(proVTag) as? BQProgressView {
                    v.isHidden = false
                    v.setProgressNum(recive: 0, total: 0)
                } else {
                    let v = BQProgressView(frame: CGRect(x: (sizeW - 30) * 0.5, y: (sizeH - 30) * 0.5, width: 30, height: 30))
                    v.tag = proVTag
                    addSubview(v)
                }
            }

            kf.setImage(with: URL(string: url), placeholder: holderImg) { [weak self] recSize, totalSize in
                if let v = self?.viewWithTag(proVTag) as? BQProgressView {
                    BQLogger.log("进度更新\(needProgress): 接收\(recSize) 大小\(totalSize)")
                    v.setProgressNum(recive: Int(recSize), total: Int(totalSize))
                }
            } completionHandler: { [weak self] res in
                if let v = self?.viewWithTag(proVTag) {
                    v.isHidden = true
                }
                if let handle = completeHandler {
                    switch res {
                    case let .success(result):
                        handle(.success(result.image))
                    case let .failure(err):
                        handle(.failure(BQError(0, err.localizedDescription)))
                    }
                }
            }
        }

        static func prefetchLoadImgUrl(urls: [URL]) {
            let preFetcher = ImagePrefetcher(urls: urls)
            preFetcher.start()
        }

        static func clearCache(_ handle: VoidBlock? = nil) {
            ImageCache.default.clearCache {
                if let block = handle {
                    block()
                }
            }
        }

        static func cacheSize(_ handle: @escaping StrBlock) {
            ImageCache.default.calculateDiskStorageSize { res in
                switch res {
                case let .success(re):
                    handle(re.toDiskSize())
                case .failure:
                    handle(nil)
                }
            }
        }

        func hasImageCache(_ url: String) -> Bool {
            return ImageCache.default.isCached(forKey: url)
        }
    }

#endif
