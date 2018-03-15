//
//  BaseRouter.swift
//  Twignature
//
//  Created by Anton Muratov on 9/12/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class BaseRouter {
	private(set) weak var topController: UIViewController? {
		didSet {
			assert(topController != nil)
		}
	}
	
	// MARK: - Init

    init(initialController: UIViewController) {
        topController = initialController
    }
	
	private func getTopMostViewController() -> UIViewController? {
		guard var topVC = UIApplication.shared.keyWindow?.rootViewController else {
			return nil
		}

		while let presentedViewController = topVC.presentedViewController {
			topVC = presentedViewController
		}

		return topVC
	}
	
	func getNavController() -> UINavigationController? {
		if let navController = topController as? UINavigationController
			?? topController?.navigationController
			?? topController?.view.window?.rootViewController as? UINavigationController
			?? topController?.view.window?.rootViewController?.navigationController {
			return navController
		}
		
		let topMostController = getTopMostViewController()
		return (topMostController as? UINavigationController) ?? topMostController?.navigationController
	}
	
    func show(_ viewController: UIViewController, animated: Bool = true) {
		let navController = getNavController()
		
		navController?.pushViewController(viewController, animated: animated)
        topController = viewController
    }
    
    func back(animated: Bool = true) {
        let navigationVC = topController?.navigationController
        navigationVC?.popViewController(animated: animated)
        topController = navigationVC?.topViewController
    }
    
    func present(_ viewController: UIViewController, animated: Bool = true) {
		if topController == nil {
			topController = getTopMostViewController()
		}
        topController?.present(viewController, animated: animated)
        topController = viewController
    }
    
    func dismiss(animated: Bool = true) {
		guard let newTopViewController = controllerToReturn ?? getTopMostViewController() else {
			return
		}
		
		topController?.dismiss(animated: animated)
		topController = newTopViewController
    }
	
	var canDissmiss: Bool {
		return controllerToReturn != nil
	}
	
	private var controllerToReturn: UIViewController? {
		let presentingViewController = topController?.presentingViewController
		
		if let navController = presentingViewController as? UINavigationController {
			return navController.viewControllers.last
		} else {
			return presentingViewController
		}
	}
}
