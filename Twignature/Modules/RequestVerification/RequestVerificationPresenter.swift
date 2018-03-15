//
//  RequestVerificationPresenter.swift
//  Twignature
//
//  Created by mac on 01.11.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class RequestVerificationPresenter {
    
    //MARK: - Init
    required init(controller: RequestVerificationViewController,
                  interactor: RequestVerificationInteractor,
                  coordinator: RequestVerificationCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
    }
    
    //MARK: - Private -
    fileprivate let coordinator: RequestVerificationCoordinator
    fileprivate unowned var controller: RequestVerificationViewController
    fileprivate var interactor: RequestVerificationInteractor

    func viewIsReady() {
        guard Session.current?.user.isVerified ?? true else { return }
        let alertController = UIAlertController(title: nil,
                message: "You are already verified",
                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { [weak self] _ in
            self?.coordinator.dismiss()
        }
        alertController.addAction(okAction)
        self.controller.present(alertController, animated: false)
    }

	func backAction() {
		coordinator.dismiss()
	}
    
    func submitAction() {
        guard let message = controller.reasonTextView.text, !message.isEmpty,
            let phone = controller.phoneTextField.text, !phone.isEmpty,
            let email = controller.emailTextField.text, !email.isEmpty,
            let name = controller.nameTextField.text, !name.isEmpty else {
                controller.showError(TwignatureError.allFieldsAreMandory)
                return
        }
        controller.showHUD()
        interactor.submitVerification(WithMessage: message,
                                      phone: phone,
                                      email: email,
                                      name: name) { [weak self] (result) in
                                        switch result {
                                        case .success:
                                            self?.controller.hideHUD()
                                            self?.controller.showSuccess(with: R.string.profile.verificationRequestSendedSuccessfully())

                                            self?.coordinator.dismiss()
                                        case .failure(let error):
                                            self?.controller.hideHUD()
                                            self?.controller.showError(error)
                                        }
        }
    }
}
