//
//  UserListWireframe.swift
//  Twignature
//
//  Created by Ivan Hahanov on 10/11/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias UserListConfiguration = (UserListPresenter) -> Void

class UserListWireframe {
    class func setup(_ viewController: UserListViewController,
                     withCoordinator coordinator: UserListCoordinator,
                     configutation: UserListConfiguration? = nil) {
        let interactor = UserListInteractor()
        let presenter = UserListPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
