//
//  ProfileWireframe.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/6/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias ProfileConfiguration = (ProfilePresenter) -> Void

class ProfileWireframe {
    class func setup(_ viewController: ProfileViewController,
                     withCoordinator coordinator: ProfileCoordinator,
                     configutation: ProfileConfiguration? = nil) {
        let interactor = ProfileInteractor()
        let presenter = ProfilePresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
