//
//  DefaultsKeys+Help.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/19.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    var wallpapers: DefaultsKey<String> {
        .init("wallpapers", defaultValue: "")
    }
    
    var homeWallpaper: DefaultsKey<String> {
        .init("homeWallpaper", defaultValue: "")
    }
    
    var wallpaperChange: DefaultsKey<Int> {
        .init("wallpaperChange", defaultValue: 0)
    }
    
    var language: DefaultsKey<String> {
        .init("language", defaultValue: "zh-Hans")
    }
    
    var websites: DefaultsKey<String> {
        .init("websites", defaultValue: "")
    }
    
    var bigCell: DefaultsKey<Bool> {
        .init("bigCell", defaultValue: true)
    }
    
    
}
