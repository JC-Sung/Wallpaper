//
//  UIColor+Help.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/19.
//

import UIKit

extension UIColor {
    convenience init(r:UInt32 ,g:UInt32 , b:UInt32 , a:CGFloat = 1.0) {
        self.init(red: CGFloat(r) / 255.0,
                  green: CGFloat(g) / 255.0,
                  blue: CGFloat(b) / 255.0,
                  alpha: a)
    }
    
    class func hex(hexString: String) -> UIColor {
        if hexString.count < 1 { return UIColor.clear }
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if cString.count < 6 { return UIColor.black }
        
        let index = cString.index(cString.endIndex, offsetBy: -6)
        let subString = cString[index...]
        if cString.hasPrefix("0X") { cString = String(subString) }
        if cString.hasPrefix("#") { cString = String(subString) }
        
        if cString.count != 6 { return UIColor.black }
        
        var range: NSRange = NSMakeRange(0, 2)
        let rString = (cString as NSString).substring(with: range)
        range.location = 2
        let gString = (cString as NSString).substring(with: range)
        range.location = 4
        let bString = (cString as NSString).substring(with: range)
        
        var r: UInt32 = 0x0
        var g: UInt32 = 0x0
        var b: UInt32 = 0x0
        
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(r: r, g: g, b: b)
    }
}


extension UIColor {
    
    class var tabmanPrimary: UIColor {
        UIColor(red: 0.56, green: 0.18, blue: 0.89, alpha: 1.00)
    }
    
    class var tabmanSecondary: UIColor {
        UIColor(red: 0.29, green: 0.00, blue: 0.88, alpha: 1.00)
    }
    
    class var tabmanForeground: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .white
                default:
                    return UIColor(red: 0.56, green: 0.18, blue: 0.89, alpha: 1.00)
                }
            }
        } else {
            return UIColor(red: 0.56, green: 0.18, blue: 0.89, alpha: 1.00)
        }
    }
}
