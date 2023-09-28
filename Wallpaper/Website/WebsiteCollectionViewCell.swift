//
//  WebsiteCollectionViewCell.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/25.
//

import Foundation
import UIKit


class WebsiteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconV: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var V: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconV.layer.cornerRadius = 60/2.0
        iconV.layer.masksToBounds = true
        
        icon.layer.cornerRadius = (60-12)/2.0
        icon.layer.masksToBounds = true
        icon.layer.borderColor = UIColor(r: 238, g: 238, b: 238).cgColor
        icon.layer.borderWidth = 0.5
        
        addBtn.layer.cornerRadius = 4.0
        addBtn.layer.masksToBounds = true
        addBtn.layer.borderColor = UIColor(r: 238, g: 238, b: 238).cgColor
        addBtn.layer.borderWidth = 0.5
        
        V.layer.cornerRadius = 10
        V.layer.masksToBounds = true
    }
    
    var item: WebsiteItem? {
        didSet {
            guard let data = item else { return }
            icon.setImage(fromURL: data.src, keepCurrentImageWhileLoading: true)
            name.text = data.name
            desc.text = data.description
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
        guard let data = item else { return }
        HomeCollectionWebs.shared.addWeb(web: data)
    }
    
}
