//
//  ImageDownloadTool.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/19.
//

import Foundation
import Kingfisher


class ImageDownloadTool {
    
    public static func downloadNetworkImage(
        with url: URL,
        cancelOrigianl: Bool = true,
        options: KingfisherOptionsInfo,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((UIImage?) -> Void)? = nil
    ) {
        let key = url.cacheKey
        if ImageCache.default.isCached(forKey: key) {
            ImageCache.default.retrieveImage(
                forKey: key,
                options: options
            ) { (result) in
                switch result {
                case .success(let value):
                    completionHandler?(value.image)
                case .failure:
                    completionHandler?(nil)
                }
            }
            return
        }
        ImageDownloader.default.downloadImage(
            with: url,
            options: options,
            progressBlock: progressBlock
        ) { (result) in
            switch result {
            case .success(let value):
                DispatchQueue.global().async {
                    if let gifImage = DefaultImageProcessor.default.process(
                        item: .data(value.originalData),
                        options: .init([])
                    ) {
                        if cancelOrigianl {
                            ImageCache.default.store(
                                gifImage,
                                original: value.originalData,
                                forKey: key
                            )
                        }
                        DispatchQueue.main.async {
                            completionHandler?(gifImage)
                        }
                        return
                    }
                    if cancelOrigianl {
                        ImageCache.default.store(
                            value.image,
                            original: value.originalData,
                            forKey: key
                        )
                    }
                    DispatchQueue.main.async {
                        completionHandler?(value.image)
                    }
                }
            case .failure:
                completionHandler?(nil)
            }
        }
    }
    
}

