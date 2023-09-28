//
//  WallpaperListModel.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/20.
//

import Foundation
import HandyJSON

class WallpaperListModel: HandyJSON {
    var code: Int = 0
    var message: String = ""
    var timestamp: Int = 0
    var data = WallpaperListData()
    required init() {}
}

class WallpaperListData: HandyJSON {
    var totalPages: Int = 0
    var nextPage: Int = 0
    var count: Int = 0
    var list = [WallpaperItem]()
    required init() {}
}


class WallpaperBingModel: HandyJSON {
    var code: Int = 0
    var message: String = ""
    var timestamp: Int = 0
    var data = WallpaperItem()
    required init() {}
}
