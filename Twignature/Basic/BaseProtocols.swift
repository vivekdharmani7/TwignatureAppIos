//
//  BaseViewing.swift
//  Twignature
//
//  Created by user on 5/13/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import UIKit.UINavigationController
import SafariServices

protocol BaseViewing {
    func showHUD()
    func hideHUD()
    func showError(with message: Error)
    func showAlert(with message: String)
    func showSuccess(with message: String)
    func show(alert: UIAlertController)
}

protocol BaseCoordinator {
    var router: BaseRouter! { get set }
    
    init(router: BaseRouter, _ flow: AppFlow?)
    
    func show(_ viewController: UIViewController)
    func back()
    func present(_ viewController: UIViewController)
    func dismiss()
	func showActivityController(forResource url: URL!)
}

extension BaseCoordinator {
    
    func show(_ viewController: UIViewController) {
        router.show(viewController)
    }
    
    func back() {
        router.back()
    }
    
    func present(_ viewController: UIViewController) {
        router.present(viewController)
    }
    
    func dismiss() {
        router.dismiss()
    }
	
	func showActivityController(forResource url: URL!) {
		let activityViewController = UIActivityViewController(activityItems: [url],
		                                                      applicationActivities: nil)
		router.topController?.present(activityViewController, animated: true)
	}
}

class BaseFlow: BaseCoordinator {
	
	var router: BaseRouter!
	var appFlow: AppFlow?
	
	required init(router: BaseRouter, _ flow: AppFlow?) {
		self.router = router
		self.appFlow = flow
	}
}
