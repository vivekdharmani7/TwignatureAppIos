//
//  UserLikesWireframe.swift
//  Twignature
//
//  Created by Ivan Hahanov on 10/11/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias UserLikesConfiguration = (TweetsForUserPresenter) -> Void

class UserLikesWireframe {
    class func setup(_ viewController: TweetsForUserViewController,
                     withCoordinator coordinator: TweetsForUserCoordinator,
                     configutation: UserLikesConfiguration? = nil) {
        let interactor = UserLikesInteractor()
        let presenter = TweetsForUserPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
		presenter.textForNodata = R.string.tweets.noLikes()
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
