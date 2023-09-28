//
//  AppDelegate.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/18.
//

import UIKit
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        configKeyboard()
        return true
    }

    func configKeyboard() {
        let manager = IQKeyboardManager.shared
        manager.enable = true
        manager.shouldResignOnTouchOutside = true
        manager.shouldToolbarUsesTextFieldTintColor = false
        manager.toolbarTintColor = UIColor.black
        manager.enableAutoToolbar = false
        manager.toolbarDoneBarButtonItemText = "完成"
        manager.keyboardDistanceFromTextField = 40.0
        manager.shouldShowToolbarPlaceholder = true
        
        IQKeyboardManager.shared.disabledToolbarClasses = []
    }

}

