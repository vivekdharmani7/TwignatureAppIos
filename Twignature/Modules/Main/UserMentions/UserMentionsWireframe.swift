//
//  UserMentionsWireframe.swift
//  Twignature
//
//  Created by mac on 12.10.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class UserMentionsWireframe {
	
	class func setup(_ viewController: TweetsForUserViewController,
	                 withCoordinator coordinator: TweetsForUserCoordinator,
	                 configutation: TweetsForUserConfiguration? = nil) {
		let interactor = UserMentionsInteractor()
		let presenter = TweetsForUserPresenter(controller: viewController,
		                                       interactor: interactor,
		                                       coordinator: coordinator)
		presenter.textForNodata = R.string.tweets.noMentions()
		viewController.presenter = presenter
		interactor.presenter = presenter
		configutation?(presenter)
	}
}
