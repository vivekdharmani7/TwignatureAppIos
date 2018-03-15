//
//  UIViewControllerExtensions.swift
//  Twignature
//
//  Created by Anton Muratov on 9/10/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit.UIViewController

extension UIViewController: AlertShowing, HUDShowing { }

extension UIViewController: Identifierable {
    
    static func instantiate<T: UIViewController>(from storyboard: UIStoryboard) -> T {
        guard let vc = storyboard.instantiateViewController(withIdentifier: T.identifier) as? T else {
            fatalError("Wrong VC - \(T.identifier)")
        }
        return vc
    }
}

extension UIViewController {
    
    static func topViewController(from viewController: UIViewController?) -> UIViewController? {
        if let tabBarViewController = viewController as? UITabBarController {
            return topViewController(from: tabBarViewController.selectedViewController)
        } else if let navigationController = viewController as? UINavigationController {
            return topViewController(from: navigationController.visibleViewController)
        } else if let presentedViewController = viewController?.presentedViewController {
            return topViewController(from: presentedViewController)
        } else {
            return viewController
        }
    }
    
}
