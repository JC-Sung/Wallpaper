//
//  WallpaperPostModel.swift
//  LetvPosterExtension
//
//  Created by YEHWANG-iOS on 2024/3/15.
//

import Foundation
import HandyJSON
import Kingfisher

class WallpaperPostModel: HandyJSON {
    var status: Int = 0
    var key: String = ""
    var success: Bool = false
    var timestamp: Int = 0
    var data = [WallpaperPostItem]()
    required init() {}
}

class WallpaperPostItem: HandyJSON {
    var _id: String = ""
    var colors = [String]()
    var tags = [String]()
    var like: Int = 0
    var rate: Int = 0
    var clients = [String]()
    var source: String = ""
    var dimensions: String = ""
    var imgId: String = ""
    var src = WallpaperPostSrc()
    var similarColors = [String]()
    var from: String = ""
    var weight: String = ""
    var imageSize: CGSize = CGSize(width: 2, height: 3)
    
    required init() {}
    
//    func didFinishMapping() {
//        /**
//         "dimensions" : "2869 px x  4158px"
//         "dimensions" : "3024px x 3024px",
//         */
//        imageSize = getImageSize(dimensions: dimensions)
//    }
//    
//    func getImageSize(dimensions: String) -> CGSize {
//        var size: CGSize = CGSize(width: 2, height: 3)
//        if dimensions.count > 0 {
//            var dim = dimensions.replacingOccurrences(of: "px", with: "")
//            dim = dim.replacingOccurrences(of: " ", with: "")
//            let arr = dim.components(separatedBy: "×")
//            if arr.count == 2 {
//                let width = Double(arr[0]) ?? 0
//                let height = Double(arr[1]) ?? 0
//                size = CGSize(width: width, height: height)
//            }
//        }
//        return size
//    }
}

class WallpaperPostSrc: HandyJSON {
    var smallSrc: String = ""
    var mediumSrc: String = ""
    var bigSrc: String = ""
    var originalSrc: String = ""
    var rawSrc: String = ""
    
    var smallURL: URL?
    var mediumURL: URL?
    var bigURL: URL?
    var originalURL: URL?
    var rawURL: URL?
    
    //小组件需要
    var pic: UIImage? = UIImage(named: "snapback")
    
    func didFinishMapping() {
        
        smallURL = URL(string: smallSrc.trimmingCharacters(in: .whitespaces).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)
        mediumURL = URL(string: mediumSrc.trimmingCharacters(in: .whitespaces).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)
        bigURL = URL(string: bigSrc.trimmingCharacters(in: .whitespaces).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)
        originalURL = URL(string: originalSrc.trimmingCharacters(in: .whitespaces).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)
        rawURL = URL(string: rawSrc.trimmingCharacters(in: .whitespaces).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)
        
        if let url = smallURL, let data = try? Data(contentsOf: url) {
            pic = UIImage(data: data)
        }
    }
    
    required init() {}
}

