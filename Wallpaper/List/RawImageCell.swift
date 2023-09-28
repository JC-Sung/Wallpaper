//
//  RawImageCell.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/22.
//

import Foundation
import Lantern


/// 加上进度环的Cell
class RawImageCell: LanternImageCell {

    /// 查看原图按钮
    var rawButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.08)
        button.setTitle("下载", for: .normal)
        button.setTitle("下载", for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1 / UIScreen.main.scale
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
    }()
    
    private var rawURLString: String?
    
    override func setup() {
        super.setup()
        rawButton.addTarget(self, action: #selector(onRawImageButton), for: .touchUpInside)
        addSubview(rawButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rawButton.sizeToFit()
        rawButton.bounds.size.width += 14
        rawButton.center = CGPoint(x: bounds.width / 2,
                                   y: bounds.height - 35 - rawButton.bounds.height)
    }
    
    func reloadData(placeholder: UIImage?, rawURLString: String?) {
        self.rawURLString = rawURLString
        imageView.setImage(fromURL: rawURLString, placeholder: placeholder, resize: 300, completionHandler: { _ in
            
        })
    }
    
    @objc func onRawImageButton() {
        if let src = self.rawURLString, src.count > 0, let url = URL(string: src) {
            ImageDownloadTool.downloadNetworkImage(with: url, options: [.backgroundDecode], completionHandler:  { image in
                guard let img = image else { return }
                PhotoSaveTool.savePhotoWithImage(img)
            })
        }
    }
}

