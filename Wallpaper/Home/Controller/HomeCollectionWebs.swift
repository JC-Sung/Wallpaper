//
//  HomeCollectionWebs.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/26.
//

import Foundation
import SwiftyUserDefaults
import HandyJSON

class HomeCollectionWebs: NSObject {
    
    static let shared = HomeCollectionWebs()
    
    var webs = Array<WebsiteItem>()
    
    override init() {
        super.init()
        //初始化的时候就会读取缓存
        self.initWebs()
    }
    
    private func initWebs() {
        let obj = Defaults.websites
        if obj.count > 0, let model = JSONDeserializer<WebsiteModel>.deserializeFrom(json: obj) {
            self.webs = model.icons
        }
    }
    
    public func addWeb(web: WebsiteItem) {
        self.webs.removeAll(where: { $0.url == web.url })
        self.webs.append(web)
        self.synchronizy()
        ShowMessages.showToast(msg: "添加成功")
    }
    
    public func remove(url: String) {
        self.webs.removeAll(where: { $0.url == url })
        self.synchronizy()
        ShowMessages.showToast(msg: "删除成功")
    }
    
    private func synchronizy() {
        let data = WebsiteModel()
        data.icons = self.webs
        Defaults.websites = data.toJSONString() ?? ""
    }
    
    public func synchronizyWebs(_ webs: [WebsiteItem]) {
        self.webs = webs
        let data = WebsiteModel()
        data.icons = self.webs
        Defaults.websites = data.toJSONString() ?? ""
    }
}
