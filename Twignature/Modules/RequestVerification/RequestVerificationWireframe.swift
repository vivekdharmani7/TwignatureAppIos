//
//  RequestVerificationWireframe.swift
//  Twignature
//
//  Created by mac on 01.11.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias RequestVerificationConfiguration = (RequestVerificationPresenter) -> Void

class RequestVerificationWireframe {
    class func setup(_ viewController: RequestVerificationViewController,
                     withCoordinator coordinator: RequestVerificationCoordinator,
                     configutation: RequestVerificationConfiguration? = nil) {
        let interactor = RequestVerificationInteractor()
        let presenter = RequestVerificationPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
