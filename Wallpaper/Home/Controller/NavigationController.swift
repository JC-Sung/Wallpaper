//
//  NavigationController.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/19.
//

import Foundation
import UIKit

class NavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        guard let topVC = topViewController else { return .lightContent }
        return topVC.preferredStatusBarStyle
    }
    
    override open var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    override open var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    
    var popDelegate: UIGestureRecognizerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.popDelegate = self.interactivePopGestureRecognizer?.delegate
        self.delegate = self
        
        if #available(iOS 13.0, *) {
            //不设置的话。默认有滚动视图时，导航栏的透明度会变化
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.shadowImage = UIImage()
            appearance.shadowColor = .clear
            
            appearance.titleTextAttributes = gettitleTextAttributes()
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            // Fallback on earlier versions
        }
        
        self.navigationBar.barTintColor = .white
        self.navigationBar.tintColor = .black
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().tintColor = .black
        self.navigationBar.titleTextAttributes = gettitleTextAttributes()
        UINavigationBar.appearance().titleTextAttributes = gettitleTextAttributes()
        self.navigationBar.shadowImage = UIImage()
        
        self.addPanGess()
        
    }
    
    func gettitleTextAttributes() -> [NSAttributedString.Key : Any] {
        return [NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .medium)]
    }
    
    //返回按钮
      @objc  func backToPrevious(){

          if ((self.presentedViewController != nil || self.presentingViewController != nil) && self.viewControllers.count == 1) {
              self.dismiss(animated: true, completion: nil)
          } else {
              self.popViewController(animated: true)
          }
          
      }

    //很重要当在栈顶控制器时，再侧滑返回，页面就会卡死，所以root时要禁用返回手势
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController == self.viewControllers[0] {
            self.interactivePopGestureRecognizer!.delegate = self.popDelegate
        } else {
            self.interactivePopGestureRecognizer!.delegate = nil
        }

    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count > 0 {// 隐藏底部栏
            // 当前导航栏, 只有第一个viewController push的时候设置隐藏
            if (self.viewControllers.count == 1) {
                viewController.hidesBottomBarWhenPushed = true
                //以此解决iOS 14上TabBar隐藏的bug
            }
        } else {
            viewController.hidesBottomBarWhenPushed = false
        }
        
        if self.viewControllers.count > 0 {
            
            let leftBarBtn = UIBarButtonItem(image: UIImage(named: "back_yun"), style: .plain, target: self,action: #selector(backToPrevious))
            if #available(iOS 14.0, *) {
                leftBarBtn.menu = self.menu()
            } else {
                // Fallback on earlier versions
            }
            viewController.navigationItem.leftBarButtonItem = leftBarBtn
            // 如果自定义返回按钮后, 滑动返回可能失效, 需要添加下面的代码
            weak var weakSelf = viewController
            self.interactivePopGestureRecognizer!.delegate = weakSelf as? UIGestureRecognizerDelegate
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    /// 将导航栏的右滑手势添加到 view 上面，全屏侧滑返回
    func addPanGes() {
        
        interactivePopGestureRecognizer?.delegate = self
        guard  let targets = interactivePopGestureRecognizer?.value(forKey: "_targets") as?[AnyObject] else {
            return
        }
        let dict = targets[0]
        //拿到action
        let target = dict.value(forKey: "target") as Any
        //通过字典无法拿到action，这里通过Selector方法包装action
        let action = Selector(("handleNavigationTransition:"))
        //拿到target action 创建pan手势并添加到全屏view上
        let gesture = UIPanGestureRecognizer(target: target, action: action)
        view.addGestureRecognizer(gesture)
        // 这里需要将导航栏的右滑手势去掉
        self.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func addPanGess() {
        guard let interactionGes = interactivePopGestureRecognizer else { return }
        guard let targetView = interactionGes.view else { return }
        guard let internalTargets = interactionGes.value(forKeyPath: "targets") as? [NSObject] else { return }
        guard let internalTarget = internalTargets.first?.value(forKey: "target") else { return }
        let action = Selector(("handleNavigationTransition:"))

        let fullScreenGesture = UIPanGestureRecognizer(target: internalTarget, action: action)
        fullScreenGesture.delegate = self
        targetView.addGestureRecognizer(fullScreenGesture)
        interactionGes.isEnabled = false
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let isLeftToRight = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
        guard let ges = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        if ges.translation(in: gestureRecognizer.view).x * (isLeftToRight ? 1 : -1) <= 0
            || disablePopGesture {
            return false
        }
        return viewControllers.count != 1;
    }
    
    @available(iOS 13.0, *)
    func menu() -> UIMenu {
        //实现系统的返回菜单
        let vcs:[UIViewController] = self.viewControllers
        var actions = [UIAction]()
        for vc in vcs {
            var title = "返回"
            if vc.title?.isEmpty == false {
                title = vc.title ?? "返回"
            }
            if vc.navigationItem.title?.isEmpty == false {
                title = vc.navigationItem.title ?? "返回"
            }
            let action = UIAction(title: title) { _ in
                self.popToViewController(vc, animated: true)
            }
            actions.append(action)
        }
        return UIMenu(children: actions.reversed())
    }
    
}


extension UINavigationController {
    
    func pushFadeViewController(viewController: UIViewController) {
        let transition: CATransition = CATransition()
        transition.duration = 0.25
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = .fade
        self.view.layer.add(transition, forKey: "translationKeyframeAniFade")
        pushViewController(viewController, animated: false)
    }

    func fadePopViewController() {
        let transition: CATransition = CATransition()
        transition.duration = 0.25
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = .fade
        self.view.layer.add(transition, forKey: "translationKeyframeAniFade")
        popViewController(animated: false)
    }
}


extension UINavigationController {
    
    private struct AssociatedKeys {
        static var disablePopGesture: Void?
    }
    
    var disablePopGesture: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.disablePopGesture) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.disablePopGesture, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
