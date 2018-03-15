//
//  SealDetailsWireframe.swift
//  Twignature
//
//  Created by mac on 04.10.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias SealDetailsConfiguration = (SealDetailsPresenter) -> Void

class SealDetailsWireframe {
    class func setup(_ viewController: SealDetailsViewController,
                     withCoordinator coordinator: SealDetailsCoordinator,
                     configutation: SealDetailsConfiguration? = nil) {
        let interactor = SealDetailsInteractor()
        let presenter = SealDetailsPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
