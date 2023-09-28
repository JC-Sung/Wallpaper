//
//  WallpaperCell.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/18.
//

import UIKit
import Foundation
import Kingfisher

class WallpaperCell: UICollectionViewCell {
    
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var downBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        icon.backgroundColor = UIColor.hex(hexString: "#f2f2f2")
        
        if #available(iOS 13.0, *) {
            downBtn.isHidden = true
        } else {
            downBtn.isHidden = false
        }
    }
    
    var item: WallpaperItem? {
        didSet {
            guard let data = item else { return }
            if let color = data.colors.first {
                self.icon.backgroundColor = UIColor.hex(hexString: color)
            }
            self.icon.setImage(fromURL: data.src?.smallSrc)
            
        }
    }
    
    var listItem: WallpaperItem? {
        didSet {
            guard let data = listItem else { return }
            
            if let color = data.colors.first {
                self.icon.backgroundColor = UIColor.hex(hexString: color)
            }
            self.icon.setImage(fromURL: data.src?.rawSrc, resize: 300)
            
        }
    }
    
    @IBAction func downAction(_ sender: UIButton) {
        
    }
}


