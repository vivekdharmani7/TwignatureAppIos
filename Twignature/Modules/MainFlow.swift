//
//  MainFlow.swift
//  Twignature
//
//  Created by Anton Muratov on 9/12/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

class MainFlow: BaseFlow {}

protocol CanShowUserProfile {
	func showUserProfile(userId: String, userScreenName: String)
}

protocol CanShowSealDetails {
	func displaySealDetails(_ tweetViewModel: FeedViewModel.TweetViewItem)
	func displaySealDetails(withViewModel viewModel: SealDetailsViewModel)
}

protocol CanShowHashtagSearch {
	func showHashtagsSearch(withPreferedText text: String)
}

extension ProfileFlow: CanShowHashtagSearch {
	func showHashtagsSearch(withPreferedText text: String) {
		guard let hashtagsSearch = R.storyboard.hashtagsSearch.hashtagsSearchViewController() else {
			fatalError("Can't instantiate view controller")
		}
		HashtagsSearchWireframe.setup(hashtagsSearch,
				withCoordinator: self
		) { presenter in
			presenter.setHashtag(text)
		}
		router.show(hashtagsSearch)
	}
}

extension MainFlow: CanShowHashtagSearch {
	func showHashtagsSearch(withPreferedText text: String) {
		guard let hashtagsSearch = R.storyboard.hashtagsSearch.hashtagsSearchViewController() else {
			fatalError("Can't instantiate view controller")
		}
		HashtagsSearchWireframe.setup(hashtagsSearch,
				withCoordinator: self
		) { presenter in
			presenter.setHashtag(text)
		}
		router.show(hashtagsSearch)
	}
}

extension CanShowUserProfile where Self: ProfileCoordinator {
	func showUserProfile(userId: String, userScreenName: String) {
		guard let profileVC = R.storyboard.profile.profileViewController() else {
			return
		}
		ProfileWireframe.setup(profileVC, withCoordinator: self) { (configurator) in
			configurator.userId = userId
			configurator.userScreenName = userScreenName
		}
		
		let navController = BaseNavigationController(rootViewController: profileVC)
		navController.view.backgroundColor = UIColor.white
		router.present(navController)
	}
}

extension TweetDetailsCoordinator {
	func showTweetDetails(tweet: Tweet) {
		let vc = R.storyboard.tweetDetails.tweetDetailsViewController()!
		let configuration = TweetDetailsConfiguration(tweet: tweet, tweedId: nil)
		TweetDetailsWireframe.setup(vc, withCoordinator: self, configuration: configuration)
		router.show(vc, animated: true)
	}
}

extension CreateTweetCoordinator {
	func showCreateTweet(withCompletion completion: @escaping ((Bool) -> Void)) {
		showCreateTweet(inReplyTo: nil, withCompletion: completion)
	}
	
	func showCreateTweet(inReplyTo: Tweet? = nil, withCompletion completion: @escaping ((Bool) -> Void)) {
		guard let vc = R.storyboard.tweets.createTweetViewController() else {
			return
		}

		CreateTweetWireframe.setup(vc, withCoordinator: self) { (presenter) in
			presenter.postCreatedHandler = completion
			presenter.tweetToReply = inReplyTo
		}
		router.present(UINavigationController(rootViewController: vc))
	}
	
	func showCreateTweet(asQuoteTo: Tweet? = nil, withCompletion completion: @escaping ((Bool) -> Void)) {
		guard let vc = R.storyboard.tweets.createTweetViewController() else {
			return
		}
		
		CreateTweetWireframe.setup(vc, withCoordinator: self) { (presenter) in
			presenter.postCreatedHandler = completion
			presenter.tweetToRetweet = asQuoteTo
		}
		router.present(UINavigationController(rootViewController: vc))
	}
	}

extension LocationDisplayerCoordinator {
	func presentLocation(_ location: Location) {
		guard let vc = R.storyboard.locationDisplayer.locationDisplayerViewController() else {
			return
		}
		LocationDisplayerWireframe.setup(vc,
		                                 withCoordinator: self) { presenter in
											presenter.location = location
		}
		router.present(BaseNavigationController(rootViewController: vc))
	}

}

extension MainFlow: FeedCoordinator, CanShowUserProfile {
}

extension MainFlow: CreateTweetCoordinator { }

extension MainFlow: LocationDisplayerCoordinator {}

extension MainFlow: SealDetailsCoordinator,
					ProfileCoordinator,
					DirectMessagePickerCoordinator,
					ConversationCoordinator,
					ChatsCoordinator {
}

extension SealDetailsCoordinator {
	
	func displaySealDetails(_ tweetViewModel: FeedViewModel.TweetViewItem) {
		let sealDetailsViewModel = SealDetailsViewModel(withTweetViewModel: tweetViewModel)
		displaySealDetails(withViewModel: sealDetailsViewModel)
	}

	func displaySealDetails(withViewModel viewModel: SealDetailsViewModel) {
		guard let vc = R.storyboard.feed.sealDetailsViewController() else {
			return
		}
		SealDetailsWireframe.setup(vc,
		                           withCoordinator: self) { presenter in
									presenter.sealDetailsViewModel = viewModel
		}
		router.present(vc)
	}
}

extension MainFlow: SideMenuCoordinator {
	func performLogout() {
		self.appFlow?.logout()
	}

	func showMyProfile() {
		guard let userId = Session.current?.user.id,
			let userScreenName = Session.current?.user.screenName else {
				return
		}
		self.showUserProfile(userId: userId, userScreenName: userScreenName)
	}

	func showTwignatureFeed() {
		guard let user = Session.current?.user,
			let vc = R.storyboard.tweetsForUser.tweetsForUserViewController() else {
			return
		}

		TwignatureFeedWireframe.setup(vc, withCoordinator: self) { presenter in
			presenter.user = user
		}
		router.show(vc)
	}

	func showVerificationRequest() {
		let verificationScreen = R.storyboard.requestVerification.requestVerificationViewController()!
		RequestVerificationWireframe.setup(verificationScreen, withCoordinator: self)
		let navController = UINavigationController(rootViewController: verificationScreen)
		navController.navigationBar.isHidden = true
		navController.view.backgroundColor = UIColor.white
		router.present(navController)
	}
	
	func showSettings() {
		let settingsController = R.storyboard.settings.settingsViewController()!
		SettingsWireframe.setup(settingsController, withCoordinator: self)
		let navController = UINavigationController(rootViewController: settingsController)
		navController.navigationBar.isHidden = true
		navController.view.backgroundColor = UIColor.white
		router.present(navController)
	}
}

extension MainFlow: RequestVerificationCoordinator {}

extension MainFlow: SettingsCoordinator {
	func showBlockedUsersList() {
		guard let vc = R.storyboard.profile.userListViewController(),
			let user = Session.current?.user else {
			return
		}
		UserListWireframe.setup(vc, withCoordinator: self) { presenter in
			presenter.title = R.string.profile.blocks()
			presenter.textForNodata = R.string.profile.noBlocked()
			presenter.user = user
			presenter.configure(endpoint: .blocks,
			                    userActionType: .unblock,
			                    hidesCellButton: false,
			                    actionMessage: "Unblock user",
			                    sideButtonTitle: "Unblock")
		}
		router.getNavController()?.setNavigationBarHidden(false, animated: true)
		router.show(vc)
	}

	func showMutedUsersList() {
		guard let vc = R.storyboard.profile.userListViewController(),
			let user = Session.current?.user else {
			return
		}
		UserListWireframe.setup(vc, withCoordinator: self) { presenter in
			presenter.title = R.string.profile.mutes()
			presenter.textForNodata = R.string.profile.noMuted()
			presenter.user = user
			presenter.configure(endpoint: .mutes,
			                    userActionType: .unmute,
			                    hidesCellButton: false,
			                    actionMessage: "Unmute user",
			                    sideButtonTitle: "Unmute")
		}
		router.getNavController()?.setNavigationBarHidden(false, animated: true)
		router.show(vc)
	}
}
