//
//  LocationDisplayerWireframe.swift
//  Twignature
//
//  Created by mac on 29.09.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias LocationDisplayerConfiguration = (LocationDisplayerPresenter) -> Void

class LocationDisplayerWireframe {
    class func setup(_ viewController: LocationDisplayerViewController,
                     withCoordinator coordinator: LocationDisplayerCoordinator,
                     configutation: LocationDisplayerConfiguration? = nil) {
        let interactor = LocationDisplayerInteractor()
        let presenter = LocationDisplayerPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
