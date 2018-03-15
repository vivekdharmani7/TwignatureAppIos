//
//  CreateTweetProtocols.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/12/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

protocol CreateTweetCoordinator: BaseCoordinator, CanShowSealDetails, BrushSettingsCoordinator {

	func showPurchasePopup()
}

extension BaseCoordinator where Self: CreateTweetCoordinator {

	func showPurchasePopup() {
		let purchaseController = R.storyboard.tweets.purchaseViewController()!
		self.router.topController?.present(purchaseController, animated: true)
	}
}
