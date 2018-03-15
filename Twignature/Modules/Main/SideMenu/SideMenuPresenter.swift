//
//  SideMenuPresenter.swift
//  Twignature
//
//  Created by mac on 05.10.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class SideMenuPresenter {
    
    //MARK: - Init
    required init(controller: SideMenuViewController,
                  interactor: SideMenuInteractor,
                  coordinator: SideMenuCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
    }
    
    //MARK: - Private -
    fileprivate let coordinator: SideMenuCoordinator
    fileprivate unowned var controller: SideMenuViewController
    fileprivate var interactor: SideMenuInteractor
	
	func viewIsReady() {
		guard let currentUser = Session.current?.user else {
			return
		}
		setupWithUser(currentUser)
	}
	
	func viewAppeared() {
		let needToShowPowerPen = UserDefaults.standard.bool(forKey: Key.isPowerPanPurchasedKey)
		controller.needToShowPurchasePowerPen(!needToShowPowerPen)
		interactor.updateCurrentUserInfo { [weak self] result in
			switch result {
			case .success(let currentUser):
				self?.setupWithUser(currentUser)
			case .failure: break
				
			}
		}
	}
	
	func setupWithUser(_ currentUser: User) {
		controller.updateProfile(currentUser.screenName, currentUser.name)
		controller.updateProfileFollowers( currentUser.followersCount, andFolloing: currentUser.friendsCount)
		guard let profileImageUrl = currentUser.profileImageUrl else {
			return
		}
		controller.updateUserProfileImage(profileImageUrl)
	}
	//MARK: - Public -
	func crossAction() {
		controller.dismiss(animated: true, completion: nil)
	}
	
	func logoutAction() {
        controller.showHUD()
        interactor.performLogout { [weak self] (result) in
            switch result {
            case .success:
                guard let strongSelf = self else { return }
                strongSelf.controller.hideHUD()
                let coordinator = strongSelf.coordinator
                strongSelf.controller.dismiss(animated: false) {
                    coordinator.performLogout()
                }
            case .failure(let error):
                self?.controller.hideHUD()
                self?.controller.showError(error)
            }
        }
		
	}
	
	func twignatureAction() {
		self.coordinator.showTwignatureFeed()
		controller.dismiss(animated: true)
	}
	
	func settingsAndPrivacyAction() {
		let coordinator = self.coordinator
		controller.dismiss(animated: true) {
			coordinator.showSettings()
		}
	}
	
	func profileAction() {
		let coordinator = self.coordinator
		controller.dismiss(animated: true) {
			coordinator.showMyProfile()
		}
	}
	
	func verificationRequestAction() {
		let coordinator = self.coordinator
		controller.dismiss(animated: true) {
			coordinator.showVerificationRequest()
		}
	}

	func purchaseSealAction() {
		guard let sealUrl = URL(string: "https://twignature.com/order-seal/#") else { return }
		self.interactor.openUrl(sealUrl)
	}

	func purchasePowerPenAction() {
		let coordinator = self.coordinator
		controller.dismiss(animated: true) {
			let purchaseController = R.storyboard.tweets.purchaseViewController()!
			coordinator.router.topController?.present(purchaseController, animated: true)
		}

	}

}
