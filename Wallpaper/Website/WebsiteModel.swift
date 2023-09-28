//
//  WebsiteModel.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/25.
//

import Foundation
import HandyJSON


class WebsiteModel: HandyJSON {
    var status: Int = 0
    var totalPages: Int = 0
    var count: Int = 0
    var success: Bool = false
    var icons = [WebsiteItem]()
    required init() {}
}

class WebsiteItem: HandyJSON {
    var isAboveall: Bool = false
    var source: String = ""
    var isInfinity: Bool = false
    var keyword: String = ""
    var src: String = ""
    var url: String = ""
    var name: String = ""
    var description: String = "无描述"
    var _id: String = ""
    var uid: String = ""
    required init() {}
}

class WebsiteTypeModel: HandyJSON {
    var types = [WebsiteTypeItem]()
    required init() {}
}

class WebsiteTypeItem: HandyJSON {
    var name: String = ""//受欢迎的
    var lang: String = "zh-CN"
    var type: String = ""//popular
    var source: String = ""//shareByUser
    var isSecleted: Bool = false
    required init() {}
}
