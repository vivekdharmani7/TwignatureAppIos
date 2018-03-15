//
//  TwitterKitExtensions.swift
//  Twignature
//
//  Created by mac on 23.10.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import TwitterKit

extension TWTRTweetView {
	
	func configure(withTweetId id: String, displayedHandler: @escaping Closure<()>) {
		let twitterClient = Session.current?.twitterApiClient
		twitterClient?.loadTweet(withID: id, completion: { [weak self] (tweet, _) in
			if tweet?.tweetID == id {
				self?.configure(with: tweet)
				displayedHandler(())
			}
		})
	}
}
