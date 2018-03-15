//
//  SideMenuWireframe.swift
//  Twignature
//
//  Created by mac on 05.10.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias SideMenuConfiguration = (SideMenuPresenter) -> Void

class SideMenuWireframe {
    class func setup(_ viewController: SideMenuViewController,
                     withCoordinator coordinator: SideMenuCoordinator,
                     configutation: SideMenuConfiguration? = nil) {
        let interactor = SideMenuInteractor()
        let presenter = SideMenuPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
