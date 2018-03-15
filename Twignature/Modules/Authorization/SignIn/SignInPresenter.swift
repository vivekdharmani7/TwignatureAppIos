//
//  SignInPresenter.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/1/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class SignInPresenter {
    
    //MARK: - Init
    required init(controller: SignInViewController,
                  interactor: SignInInteractor,
                  coordinator: SignInCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
    }
    
    //MARK: - Private -
    fileprivate let coordinator: SignInCoordinator
    fileprivate unowned var controller: SignInViewController
    fileprivate var interactor: SignInInteractor
    
    func viewIsReady() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func handleLogin() {
        interactor.login { [weak self] result in
            switch result {
            case .success:
                Session.current?.updateSessionSensetive()
				self?.coordinator.didLogin()
            case .failure(let error):
				try? Session.logout()
                self?.controller.showError(error.localizedDescription)
            }
        }
    }
	
	func termsOfUseAction() {
		guard let url = URL(string: Links.terms) else { return }
		interactor.openUrl(url)
	}
}
