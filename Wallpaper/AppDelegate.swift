//
//  AppDelegate.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/18.
//

import UIKit
import IQKeyboardManagerSwift
import WidgetKit
import SwiftyUserDefaults

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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let urlString = url.absoluteString
        
        Defaults.homeWallpaper = urlString
        //通知的前提是首页已经加载了
        NotificationCenter.default.post(name: Notification.Name("WallpaperPosterData"), object: nil, userInfo: ["url" : urlString])
        
        if urlString == "Search" {
            // 搜索
            print("search")
            self.alert(title: "Search Click", message: "search")
        } else if urlString.hasPrefix("smallCard") {
            print("small card open vid")
            let component = urlString.components(separatedBy: ",")
            if component.count > 1 {
                let vid = component[1]
                self.alert(title: "small card click", message: "vid: \(vid)")
            }
        } else if urlString.hasPrefix("episode") {
            print("medium card open vid")
            let component = urlString.components(separatedBy: ",")
            if component.count > 2 {
                let vid = component[1]
                let order = component[2]
                self.alert(title: "medium card click", message: "vid: \(vid), order: \(order)")
            }
        }
        
        return true
        
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: { _ in
            print("ok")
        }))
        self.window?.rootViewController?.present(alert, animated: true)
    }

}

