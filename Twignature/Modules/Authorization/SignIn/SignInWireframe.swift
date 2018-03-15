//
//  SignInWireframe.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/1/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias SignInConfiguration = (SignInPresenter) -> Void

class SignInWireframe {
    class func setup(_ viewController: SignInViewController,
                     withCoordinator coordinator: SignInCoordinator,
                     configutation: SignInConfiguration? = nil) {
        let interactor = SignInInteractor()
        let presenter = SignInPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
