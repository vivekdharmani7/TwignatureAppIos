//
//  SettingsWireframe.swift
//  Twignature
//
//  Created by mac on 12.10.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias SettingsConfiguration = (SettingsPresenter) -> Void

class SettingsWireframe {
    class func setup(_ viewController: SettingsViewController,
                     withCoordinator coordinator: SettingsCoordinator,
                     configutation: SettingsConfiguration? = nil) {
        let interactor = SettingsInteractor()
        let presenter = SettingsPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
