//
//  HomeWebCell.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/26.
//

import Foundation
import UIKit


class HomeWebCell: UICollectionViewCell {
    
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var icon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        icon.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        icon.layer.cornerRadius = 50/2.0
        icon.layer.masksToBounds = true
//        icon.layer.borderColor = UIColor(r: 238, g: 238, b: 238).cgColor
//        icon.layer.borderWidth = 0.5
        
        deleteBtn.isHidden = true
    }
    
    var item: WebsiteItem? {
        didSet {
            guard let item = item else { return }
            icon.setImage(fromURL: item.src)
            name.text = item.name
        }
    }
    
    var isEditing = false {
        didSet {
            if isEditing {
                if let keys = self.layer.animationKeys(), keys.contains("cellShake")  {
                    return
                }
                let keyAnimaion = CAKeyframeAnimation()
                keyAnimaion.keyPath = "transform.rotation"
                keyAnimaion.values = [-Double.pi/72, Double.pi/72, -Double.pi/72]
                keyAnimaion.isRemovedOnCompletion = false
                keyAnimaion.fillMode = .forwards
                keyAnimaion.duration = 0.3
                keyAnimaion.repeatCount = MAXFLOAT
                self.layer.add(keyAnimaion, forKey: "cellShake")
            }else{
                self.layer.removeAnimation(forKey: "cellShake")
            }
        }
    }
}
