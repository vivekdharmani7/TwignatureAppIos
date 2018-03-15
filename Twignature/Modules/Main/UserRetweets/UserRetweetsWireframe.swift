//
//  UserRetweetsWireframe.swift
//  Twignature
//
//  Created by mac on 09.10.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

class UserRetweetsWireframe {
	class func setup(_ viewController: TweetsForUserViewController,
	                 withCoordinator coordinator: TweetsForUserCoordinator,
	                 configutation: TweetsForUserConfiguration? = nil) {
		let interactor = UserRetweetsInteractor()
		let presenter = TweetsForUserPresenter(controller: viewController,
		                                       interactor: interactor,
		                                       coordinator: coordinator)
		presenter.textForNodata = R.string.tweets.noRetweets()
		viewController.presenter = presenter
		interactor.presenter = presenter
		configutation?(presenter)
	}
}
