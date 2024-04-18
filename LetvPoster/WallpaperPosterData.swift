//
//  WallpaperPosterData.swift
//  LetvPosterExtension
//
//  Created by YEHWANG-iOS on 2024/3/15.
//

import Foundation
import UIKit
import HandyJSON
import Alamofire

struct WallpaperPosterData {
    static func getTodayPoster(completion: @escaping (Result<[WallpaperPostItem], Error>) -> Void) {
        let api = Api.randomWallpaper
        RequestTool.request(url: api, httpMethod: .get) { success in
            if let model = JSONDeserializer<WallpaperPostModel>.deserializeFrom(json: success.description) {
                if model.status == 200, model.data.count > 0 {
                    completion(.success(model.data))
                } else {
                    completion(.success([]))
                }
            } else {
                completion(.success([]))
            }
        } error: { error in
            completion(.failure(error))
        }
    }
    
    static func placeholderPoster() -> WallpaperPostItem {
        let item = WallpaperPostItem()
        item.src.pic = UIImage(named: "snapback")
        return item
    }
    
}


