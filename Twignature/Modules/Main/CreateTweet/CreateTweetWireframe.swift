//
//  CreateTweetWireframe.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/12/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias CreateTweetConfiguration = (CreateTweetPresenter) -> Void

class CreateTweetWireframe {
    class func setup(_ viewController: CreateTweetViewController,
                     withCoordinator coordinator: CreateTweetCoordinator,
                     configuration: CreateTweetConfiguration? = nil) {
        let interactor = CreateTweetInteractor()
        let presenter = CreateTweetPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configuration?(presenter)
    }
}
