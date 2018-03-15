//
//  BrushSettingsWireframe.swift
//  Twignature
//
//  Created by mac on 28.11.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias BrushSettingsConfiguration = (BrushSettingsPresenter) -> Void

class BrushSettingsWireframe {
    class func setup(_ viewController: BrushSettingsViewController,
                     withCoordinator coordinator: BrushSettingsCoordinator,
                     configutation: BrushSettingsConfiguration? = nil) {
        let interactor = BrushSettingsInteractor()
        let presenter = BrushSettingsPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
