//
//  UIViewController+Help.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/20.
//

import Foundation
import UIKit

extension UIViewController {
    // Not using static as it wont be possible to override to provide custom storyboardID then
    class var storyboardID: String {
        return "\(self)"
    }
    
    static func fromStoryboard(_ appStoryboard: AppStoryboard) -> Self {
        return appStoryboard.viewController(viewControllerClass: self)
    }
    
}
