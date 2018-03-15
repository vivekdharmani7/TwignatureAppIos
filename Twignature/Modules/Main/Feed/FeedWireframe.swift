//
//  FeedWireframe.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/4/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias FeedConfiguration = (FeedPresenter) -> Void

class FeedWireframe {
    class func setup(_ viewController: FeedViewController,
                     withCoordinator coordinator: FeedCoordinator,
                     configutation: FeedConfiguration? = nil) {
        let interactor = FeedInteractor()
        let presenter = FeedPresenter(controller: viewController,
                                      interactor: interactor,
                                      coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
