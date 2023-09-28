//
//  UIView+Help.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/19.
//

import Foundation
import UIKit

public protocol ClassNameProtocol {
    static var className: String { get }
    var className: String { get }
}

public extension ClassNameProtocol {
    static var className: String {
        return String(describing: self)
    }
    
    var className: String {
        return type(of: self).className
    }
}

extension NSObject: ClassNameProtocol {}

public extension NSObjectProtocol {
    var describedProperty: String {
        let mirror = Mirror(reflecting: self)
        return mirror.children.map { element -> String in
            let key = element.label ?? "Unknown"
            let value = element.value
            return "\(key): \(value)"
            }
            .joined(separator: "\n")
    }
}

extension UIView: CAAnimationDelegate {
    
    fileprivate struct AssociatedObjectKeys {
        static var kSJCViewShakerAnimationKey = "kSJCViewShakerAnimationKey"
    }
        
    typealias Completion = (() -> Void)?
    
    private var completionBlock: Completion? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.kSJCViewShakerAnimationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.kSJCViewShakerAnimationKey) as? Completion
            return tapGestureRecognizerActionInstance
        }
    }
    
    
    func sjc_shake() {
        self.sjc_shakeWithDuration(duration: 0.5, completion: nil)
    }

    func sjc_shakeWithDuration(duration: TimeInterval, completion:Completion) {
        self.completionBlock = completion
        self.addShakeAnimationForView(view: self, duration: duration)
    }

    fileprivate func addShakeAnimationForView(view: UIView, duration: TimeInterval) {

        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        let currentTx: CGFloat = view.transform.tx
        
        animation.delegate = self
        animation.duration = duration
        animation.values = [currentTx,
                            currentTx + 10,
                            currentTx - 8,
                            currentTx + 8,
                            currentTx - 5,
                            currentTx + 5,
                            currentTx];
        animation.keyTimes = [0, 0.225, 0.425, 0.6, 0.75, 0.875, 1]
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = true
        view.layer.add(animation, forKey: AssociatedObjectKeys.kSJCViewShakerAnimationKey)
    }


    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            if let action = self.completionBlock {
                action?()
            } else {
                
            }
        }
    }
    
    func danceOnce() {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values =  [1.0,1.6,0.9,1.2,0.95,1.02,1.0]
        animation.duration = 0.75
        animation.repeatCount = 1
        animation.calculationMode = .cubic
        animation.isRemovedOnCompletion = true
        layer.add(animation, forKey: "kSJCViewDanceAnimationKey")
    }
    
    func changeCol() {
        let animation = CAKeyframeAnimation(keyPath: "backgroundColor")
        animation.values =  [UIColor.white.cgColor,
                             UIColor.hex(hexString: "#FFF5F5").cgColor,
                             UIColor.white.cgColor,
                             UIColor.hex(hexString: "#FFF5F5").cgColor,
                             UIColor.white.cgColor,]
        animation.keyTimes = [0, 0.25, 0.50, 0.75, 1]
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.duration = 1
        animation.repeatCount = 1
        animation.calculationMode = .cubic
        animation.isRemovedOnCompletion = true
        layer.add(animation, forKey: "ColorChange")
    }
}


extension UIView {
    
    //在Swift中static func 相当于class final func。禁止这个方法被重写。
    static func loadNib() -> Self {
        guard let v = Bundle.main.loadNibNamed("\(self.className)", owner: nil, options: nil)?.first as? Self else {
            fatalError("\(self.className), not found in")
        }
        return v
    }
    
    static var fromNib: Self {
        //前提：xib的名字和类名一致，xib中只有一个对应的view
        guard let v = Bundle.main.loadNibNamed("\(self.className)", owner: nil, options: nil)?.first as? Self else {
            fatalError("\(self.className), not found in")
        }
        return v
    }
    
    func shake () {
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 4, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 4, y: self.center.y))
        
        CATransaction.setCompletionBlock {
            animation.isRemovedOnCompletion = true
        }
        
        self.layer.add(animation, forKey: "position")
        
        CATransaction.commit()
        
    }
    
    func cornerRadii(radii: CGFloat) {
        self.layer.cornerRadius = radii
        self.layer.masksToBounds = true
    }
    
    @IBInspectable var cornerRadius1: Double{
        get {
            return Double(self.layer.cornerRadius)
        }
        set {
            self.layer.cornerRadius = CGFloat(newValue)
        }
    }
    
    /// The width of the layer's border, inset from the layer bounds. The border is composited above the layer's content and sublayers and includes the effects of the `cornerRadius' property. Defaults to zero. Animatable.
    @IBInspectable var borderWidth1: Double {
        get {
            return Double(self.layer.borderWidth)
        }
        set {
            self.layer.borderWidth = CGFloat(newValue)
        }
    }
    
    /// The color of the layer's border. Defaults to opaque black. Colors created from tiled patterns are supported. Animatable.
    @IBInspectable var borderColor1: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    /// The color of the shadow. Defaults to opaque black. Colors created from patterns are currently NOT supported. Animatable.
    @IBInspectable var shadowColor1: UIColor? {
        get {
            return UIColor(cgColor: self.layer.shadowColor!)
        }
        set {
            self.layer.shadowColor = newValue?.cgColor
        }
    }
    
    /// The opacity of the shadow. Defaults to 0. Specifying a value outside the [0,1] range will give undefined results. Animatable.
    @IBInspectable var shadowOpacity1: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }
    
    /// The shadow offset. Defaults to (0, -3). Animatable.
    @IBInspectable var shadowOffset1: CGSize {
        get {
            return self.layer.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
        }
    }
    
    /// The blur radius used to create the shadow. Defaults to 3. Animatable.
    @IBInspectable var shadowRadius1: Double {
        get {
            return Double(self.layer.shadowRadius)
        }
        set {
            self.layer.shadowRadius = CGFloat(newValue)
        }
    }
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func applyGradient(colours: [UIColor]) {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.addSublayer(gradient)
    }
    
    func applyGradientToTopView(colours: [UIColor], locations: [NSNumber]?) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func getRandomColor() {
        let randomRed: CGFloat = CGFloat(drand48())
        let randomGreen: CGFloat = CGFloat(drand48())
        let randomBlue: CGFloat = CGFloat(drand48())
        self.backgroundColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    enum ViewSide {
        case left, right, top, bottom
    }
    
    func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {
        
        let border = CALayer()
        border.backgroundColor = color
        
        switch side {
        case .left: border.frame = CGRect(x: frame.minX, y: frame.minY, width: thickness, height: frame.height)
        case .right: border.frame = CGRect(x: frame.maxX, y: frame.minY, width: thickness, height: frame.height)
        case .top: border.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: thickness)
        case .bottom: border.frame = CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: thickness)
        }
        
        layer.addSublayer(border)
    }
    
    func shadowBorder() {
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.14).cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 5
        self.layer.masksToBounds = false
    }
    
    func shadowBorderWithCorner() {
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.14).cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 5
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 5
    }
    
    func addShadow(location: VerticalLocation, color: UIColor = UIColor.black.withAlphaComponent(0.25), opacity: Float = 1.0, radius: CGFloat = 5.0) {
        switch location {
        case .bottom:
            addShadow(offset: CGSize(width: 0, height: 2.0), color: color, opacity: opacity, radius: radius)
        case .top:
            addShadow(offset: CGSize(width: 0, height: -2.0), color: color, opacity: opacity, radius: radius)
        }
    }
    
    func addShadow(offset: CGSize, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
}
extension UIView {

    func roundCornersWithSpecificCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            clipsToBounds = true
            layer.cornerRadius = radius
            layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}

extension UIView {
    func applyBorder(colours: UIColor) {
        self.layer.borderColor = colours.cgColor
        self.layer.borderWidth = 0.5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
    }
    
    func applyButtonBorder(colours: UIColor) {
        self.layer.borderColor = colours.cgColor
        self.layer.borderWidth = 2
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
    }
    
    func applyConfigBorder(colours: UIColor) {
        self.layer.borderColor = colours.cgColor
        self.layer.borderWidth = 1
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
    }
}


enum VerticalLocation: String {
    case bottom
    case top
}

extension UIView {
    var isShowingOnKeyWindow: Bool? {
        
        let keyWindow = UIApplication.shared.keyWindow!
        let newFrame = keyWindow.convert(self.frame, from: self.superview)
        let winBounds = keyWindow.bounds
        
        let intersects = newFrame.intersects(winBounds)
        
        return !self.isHidden && self.alpha > 0.01 && self.window == keyWindow && intersects
    }
    
    func viewConvertImage() -> UIImage? {
        let size = self.bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
