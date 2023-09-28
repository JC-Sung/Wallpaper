//
//  WallpaperModel.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/19.
//

import Foundation
import HandyJSON

class WallpaperModel: HandyJSON {
    var status: Int = 0
    var key: String = ""
    var success: Bool = false
    var timestamp: Int = 0
    var data = [WallpaperItem]()
    required init() {}
}

class WallpaperItem: HandyJSON {
    var _id: String = ""
    var colors = [String]()
    var tags = [String]()
    var like: Int = 0
    var rate: Int = 0
    var clients = [String]()
    var source: String = ""
    var dimensions: String = ""
    var imgId: String = ""
    var src: WallpaperSrc?
    var similarColors = [String]()
    var from: String = ""
    var weight: String = ""
    var imageSize: CGSize = CGSize(width: 2, height: 3)
    required init() {}
    
    func didFinishMapping() {
        /**
         "dimensions" : "2869 px x  4158px"
         "dimensions" : "3024px x 3024px",
         */
        imageSize = getImageSize(dimensions: dimensions)
    }
    
    func getImageSize(dimensions: String) -> CGSize {
        var size: CGSize = CGSize(width: 2, height: 3)
        if dimensions.count > 0 {
            var dim = dimensions.replacingOccurrences(of: "px", with: "")
            dim = dim.replacingOccurrences(of: " ", with: "")
            let arr = dim.components(separatedBy: "×")
            if arr.count == 2 {
                let width = Double(arr[0]) ?? 0
                let height = Double(arr[1]) ?? 0
                size = CGSize(width: width, height: height)
            }
        }
        return size
    }
}

class WallpaperSrc: HandyJSON {
    var smallSrc: String = ""
    var mediumSrc: String = ""
    var bigSrc: String = ""
    var originalSrc: String = ""
    var rawSrc: String = ""
    required init() {}
}
