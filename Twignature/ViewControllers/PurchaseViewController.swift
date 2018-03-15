//
// Created by mac on 01.12.2017.
// Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation
import SwiftyStoreKit

class PurchaseViewController: UIViewController {

	@IBOutlet private weak var priceButton: UIButton!
	private var priceTitle: String?

	override func viewDidLoad() {
		super.viewDidLoad()
//		guard let title = self.priceTitle else {
//			return
//		}
//		self.priceButton.setTitle(title, for: .normal)
		let value = UIInterfaceOrientation.portrait.rawValue
		UIDevice.current.setValue(value, forKey: "orientation")
		//
		self.showHUD(withText: "Receiving product info")
		SwiftyStoreKit.retrieveProductsInfo([Key.purchaseDraw]) { [weak self] result in
			self?.hideHUD()
			if let product = result.retrievedProducts.first {
				let priceString = product.localizedPrice!
				print("Product: \(product.localizedDescription), price: \(priceString)")
				self?.setPriceTitle(priceString)
			}
			else if let invalidProductId = result.invalidProductIDs.first {
				self?.showError("Invalid product identifier: \(invalidProductId)")
				self?.dismiss(animated: true)
			}
			else {
//				print("Error: \(result.error)")
				self?.showError(result.error ?? TwignatureError.unexpectedResult)
				self?.dismiss(animated: true)
			}
		}
	}

	@IBAction func didPressPurchase(_ sender: Any) {
		SwiftyStoreKit.purchaseProduct(Key.purchaseDraw, quantity: 1, atomically: false) { [weak self] result in
			switch result {
			case .success(let product):
				// fetch content from your server, then:
				if product.needsFinishTransaction {
					SwiftyStoreKit.finishTransaction(product.transaction)
				}
				print("Purchase Success: \(product.productId)")
				UserDefaults.standard.set(true, forKey: Key.isPowerPanPurchasedKey)
				let notificationName = NSNotification.Name(Key.isPowerPanPurchasedKey)
				NotificationCenter.default.post(name: notificationName, object: nil)
				self?.dismiss(animated: true)
			case .error(let error):
				switch error.code {
				case .unknown: print("Unknown error. Please contact support")
				case .clientInvalid: print("Not allowed to make the payment")
				case .paymentCancelled: break
				case .paymentInvalid: print("The purchase identifier was invalid")
				case .paymentNotAllowed: print("The device is not allowed to make the payment")
				case .storeProductNotAvailable: print("The product is not available in the current storefront")
				case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
				case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
				case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
				}
			}
		}
	}

	@IBAction func restoreButtonPressed(_ sender: Any) {
		self.showHUD(withText: "Restoring...")
		SwiftyStoreKit.restorePurchases(atomically: true) { [weak self] results in
			if results.restoreFailedPurchases.count > 0 {
				print("Restore Failed: \(results.restoreFailedPurchases)")
				self?.showError("Restore Failed")
			}
			else if results.restoredPurchases.count > 0 {
				print("Restore Success: \(results.restoredPurchases)")
				self?.showSuccess(with: "Purchase restored successfully")
				UserDefaults.standard.set(true, forKey: Key.isPowerPanPurchasedKey)
				let notificationName = NSNotification.Name(Key.isPowerPanPurchasedKey)
				NotificationCenter.default.post(name: notificationName, object: nil)
				self?.dismiss(animated: true)
			}
			else {
				self?.showError("Nothing to Restore")
			}
		}
	}

	func setPriceTitle(_ title: String) {
		self.priceTitle = title
		priceButton?.setTitle(title + " - Buy now", for: .normal)
	}
}