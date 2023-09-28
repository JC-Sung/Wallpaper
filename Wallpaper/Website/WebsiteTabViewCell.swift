//
//  WebsiteTabViewCell.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/25.
//

import Foundation
import UIKit


class WebsiteTabViewCell: UITableViewCell {
    
    @IBOutlet weak var V: UIView!
    
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        V.layer.cornerRadius = 4
        V.layer.masksToBounds = true
    }
    
    var item: WebsiteTypeItem? {
        didSet {
            guard let data = item else { return }
            name.text = data.name
            
            if #available(iOS 13.0, *) {
                V.backgroundColor = data.isSecleted ? .systemGroupedBackground : .white
            } else {
                // Fallback on earlier versions
            }
            
        }
    }
}
