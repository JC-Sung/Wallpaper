//
//  UIButton+LargeClick.swift
//  YehwangPro
//
//  Created by Yehwang on 2022/1/14.
//

import Foundation
import UIKit


extension UIButton {
    
    fileprivate struct AssociatedObjectKeys {
        static var kSJCLargeClickKey = "kSJCLargeClickKey"
        static var kSJCLargeFontkKey = "kSJCLargeFontkKey"
    }
    
    public var touchAreaInsets: UIEdgeInsets? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.kSJCLargeClickKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let edgeInsets = objc_getAssociatedObject(self, &AssociatedObjectKeys.kSJCLargeClickKey) as? UIEdgeInsets
            return edgeInsets
        }
    }
    
    public var font: UIFont! {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.kSJCLargeFontkKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
                self.titleLabel?.font = newValue
            }
        }
        get {
            let edgeInsets = objc_getAssociatedObject(self, &AssociatedObjectKeys.kSJCLargeFontkKey) as? UIFont
            return edgeInsets
        }
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let touchAreaInsets = self.isHidden ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) : (self.touchAreaInsets ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        var bounds = self.bounds
        bounds = CGRect(x: bounds.origin.x - touchAreaInsets.left,
                        y: bounds.origin.y - touchAreaInsets.top,
                        width: bounds.size.width + touchAreaInsets.left + touchAreaInsets.right,
                        height: bounds.size.height + touchAreaInsets.top + touchAreaInsets.bottom)
        if bounds.equalTo(self.bounds) {
            return super.hitTest(point, with: event)
        }
        return bounds.contains(point) ? self : nil
    }
    
}
