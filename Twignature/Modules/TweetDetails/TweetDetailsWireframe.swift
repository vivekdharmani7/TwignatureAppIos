//
//  TweetDetailsWireframe.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/18/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

struct TweetDetailsConfiguration {
	let tweet: Tweet?
	let tweedId: Int?
}

class TweetDetailsWireframe {
    class func setup(_ viewController: TweetDetailsViewController,
                     withCoordinator coordinator: TweetDetailsCoordinator,
                     configuration: TweetDetailsConfiguration? = nil) {
        let interactor = TweetDetailsInteractor()
        let presenter = TweetDetailsPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
		interactor.configuration = configuration
    }
}
