//
//  TweetsForUserWireframe.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/6/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias TweetsForUserConfiguration = (TweetsForUserPresenter) -> Void

class TweetsForUserWireframe {
    class func setup(_ viewController: TweetsForUserViewController,
                     withCoordinator coordinator: TweetsForUserCoordinator,
                     configutation: TweetsForUserConfiguration? = nil) {
        let interactor = TweetsForUserInteractor()
        let presenter = TweetsForUserPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
