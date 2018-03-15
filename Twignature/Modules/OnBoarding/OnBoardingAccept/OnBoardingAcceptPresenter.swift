//
//  OnBoardingAcceptPresenter.swift
//  Twignature
//
//  Created by mac on 18.09.17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit
import LocalAuthentication

class OnBoardingAcceptPresenter {
    
    //MARK: - Init
    required init(controller: OnBoardingAcceptViewController,
                  interactor: OnBoardingAcceptInteractor,
                  coordinator: OnBoardingAcceptCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
    }
    
    //MARK: - Private -
    fileprivate let coordinator: OnBoardingAcceptCoordinator
    fileprivate unowned var controller: OnBoardingAcceptViewController
    fileprivate var interactor: OnBoardingAcceptInteractor
	
	//MARK: - View output -
	func acceptViewAction() {
		didRequestVerification()
	}
	
	func didRequestVerification() {
		guard TouchIdValidator.isTouchIdAvailable() else {
			self.controller.showError("To continue enable biometric verification on your device")
			return
		}
		interactor.authenticateUser { [unowned self] result in
			switch result {
			case .success:
				self.coordinator.acceptButtonPressed()
			case .failure(let error):
				self.controller.showError(error)
			}
		}
	}
}
