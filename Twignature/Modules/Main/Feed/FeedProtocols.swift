//
//  FeedProtocols.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/4/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

protocol FeedCoordinator: CanShowDirectMessages, CanShowSealDetails, CanShowHashtagSearch {
	func showUserProfile(userId: String, userScreenName: String)
	func showCreateTweet(withCompletion completion: @escaping ((Bool) -> Void))
    func showCreateTweet(inReplyTo: Tweet?, withCompletion completion: @escaping ((Bool) -> Void))
	func showCreateTweet(asQuoteTo: Tweet?, withCompletion completion: @escaping ((Bool) -> Void))
	func showTweetDetails(tweet: Tweet)
	func presentLocation(_ location: Location)
	func displaySealDetails(_ tweetViewModel: FeedViewModel.TweetViewItem)
	func showDirectMessagesUserPicker(tweetToShare: Tweet?)
}

protocol FeedControllerProtocol: class {

	func setup(with viewModel: FeedViewModel)
	func append(with tweets: [Tweet])
	func scrollToTop()
	func stopLoadingMore()
	func startPullToRefresh()
	func stopPullToRefresh()
	func updateView(isSearchEnabled: Bool)
	func updateVisibleItems()
	func updateTweetItem(at index: Int)
	func setNewPostButton(_ isPro: Bool)
}