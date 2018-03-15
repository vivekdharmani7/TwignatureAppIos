//
//  TwignatureFeedWireframe.swift
//  Twignature
//
//  Created by Ivan Hahanov on 10/18/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

class TwignatureFeedWireframe {
    
    class func setup(_ viewController: TweetsForUserViewController,
                                   withCoordinator coordinator: TweetsForUserCoordinator,
                                   configutation: TweetsForUserConfiguration? = nil) {
        let interactor = TwignatureFeedInteractor()
        let presenter = TweetsForUserPresenter(controller: viewController,
                                      interactor: interactor,
                                      coordinator: coordinator)
		presenter.textForNodata = R.string.tweets.noTwignatureTweets()
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
