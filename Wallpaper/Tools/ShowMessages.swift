//
//  ShowMessages.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/19.
//

import Foundation
import SPIndicator

public enum MessagesType {
    case success
    case info
    case error
    case custom(_ image: UIImage)
    case sun
}

class ShowMessages {
    static func showToast(msg: String, type: MessagesType = .success) {
        var image: UIImage
        switch type {
        case .success:
            image = UIImage(named: "hud_success")!
        case .info:
            image = UIImage(named: "hud_info")!
        case .error:
            image = UIImage(named: "hud_error")!
        case .custom(let img):
            image = img
        default:
            image = UIImage.init(systemName: "sun.min.fill")!.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        }
        
        let indicatorView = SPIndicatorView(title: msg, preset: .custom(image))
        indicatorView.layout.iconSize = .init(width: 22, height: 22)
        indicatorView.dismissByDrag = true
        indicatorView.presentSide = .top
        indicatorView.duration = 1.0
        indicatorView.present(duration: 1.0)
    }
}

