//
//  MediaTweetsProtocols.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/9/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

protocol MediaTweetsCoordinator: BaseCoordinator, CanShowUserProfile {
	func showMediaTweets(tweets: [Tweet], initialMediaItem: MediaItem?)
}

extension MediaTweetsCoordinator {
	func showMediaTweets(tweets: [Tweet], initialMediaItem: MediaItem?) {
		guard let vc = R.storyboard.mediaTweets.mediaTweetsViewController() else {
			return
		}
		
		MediaTweetsWireframe.setup(vc, withCoordinator: self) { presenter in
			presenter.tweets = tweets
			presenter.initialMediaItem = initialMediaItem
		}
		
		router.present(vc)
	}
}
