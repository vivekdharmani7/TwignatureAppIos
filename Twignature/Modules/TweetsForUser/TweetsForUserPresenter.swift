//
//  TweetsForUserPresenter.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/6/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

extension TweetsForUserPresenter: CanShowTweetMenu {
	var menuInteractor: TweetsInteractor {
		return interactor
	}
	
	var viewController: UIViewController {
		return controller
	}
}

class TweetsForUserPresenter {
	
	var user: User!
	var textForNodata: String?
	
    //MARK: - Init
    required init(controller: TweetsForUserViewController,
                  interactor: TweetsForUserInteractor,
                  coordinator: TweetsForUserCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
		NotificationCenter.default.addObserver(self,
		                                       selector: #selector(feedShouldBeReloaded),
		                                       name: NSNotification.Name(rawValue: NotificationIdentifier.FeedShouldReload), object: nil)
    }
	
	@objc
	private func feedShouldBeReloaded() {
		guard isViewReady else {
			return
		}
		refreshTweets()
	}
    
    //MARK: - Private -
	let coordinator: TweetsForUserCoordinator
    fileprivate(set) unowned var controller: TweetsForUserViewController
    fileprivate(set) var interactor: TweetsForUserInteractor
	
	func setPreloadedTweets(tweets: [Tweet]) {
		self.tweets = tweets
	}
	
	private var tweets: [Tweet] = []
	private weak var viewModel: FeedViewModel?
	private var isViewReady = false
	
	func viewIsReady() {
		controller.textForNodata = textForNodata ?? R.string.tweets.noTweets()
		interactor.user = user
		controller.avatarURL = user.profileImageUrl
		isViewReady = true
		guard tweets.isEmpty else {
			let viewModel = FeedViewModel(tweets)
			controller.setup(with: viewModel)
			self.viewModel = viewModel
			fetchSealsForTweets(tweets)
			fetchUsersVerifiedStatus(tweets)
			return
		}
		controller.showHUD()
		refreshTweets()
	}
	
	func backAction() {
		coordinator.back()
	}
	
	func replyTap(at index: Int) {
		let tweet = tweets[index]
		coordinator.showTweetDetails(tweet: tweet)
	}
	
	func locationDidTap(at index: Int) {
		let tweet = self.tweets[index]
		guard let lat = tweet.latitude, let long = tweet.longitude else {
			return
		}
		let location = Location(lat, long)
		coordinator.presentLocation(location)
	}
	
	func profileDidTap(at index: Int, withDestination destination: TweetCellContentDestination) {
		let tweet = tweets[index]
		var selectedUser: User!
		switch destination {
			case .tweet:
				selectedUser = tweet.tweetInfo.user
			case .retweet:
				selectedUser = tweet.retweetInfo?.user ?? user
		}
		guard selectedUser != user else {
			return
		}
		coordinator.showUserProfile(userId: selectedUser.id, userScreenName: selectedUser.screenName)
	}
	
	func retweetTap(at index: Int, withSender sender: UIView) {
		let tweet = self.tweets[index]
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
		if let popoverPresentationController = alertController.popoverPresentationController {
			popoverPresentationController.sourceView = self.controller.view
			popoverPresentationController.sourceRect = sender.convert(sender.bounds, to: self.controller.view)
		}
		let nativeAction = UIAlertAction(title: R.string.tweets.retweet(), style: .default) { [weak self] _ in
			self?.interactor.retweet(tweet) { [weak self] result in
				switch result {
				case .success:
					var newTweet = tweet
					guard let requiredViewModel = self?.viewModel else { return }
					newTweet.retweetCount += 1
					newTweet.isRetweeted = true
					self?.tweets[index] = newTweet
					requiredViewModel.update(with: newTweet, at: index)
					self?.controller.updateTweetItem(at: index)
//					self?.controller.showAlert(with: R.string.tweets.tweetRetweetedSuccessfully())
				case .failure(let error):
					self?.controller.showError(error)
				}
			}
		}
		let quoteAction = UIAlertAction(title: R.string.tweets.quote(), style: .default) { [weak self] _ in
			self?.coordinator.showCreateTweet(asQuoteTo: tweet, withCompletion: { [weak self] _ in
				self?.refreshTweets()
			})
		}
		let cancelAction = UIAlertAction(title: R.string.tweets.cancel(), style: .cancel) { _ in
		}
		// alert controller
		alertController.addAction(nativeAction)
		alertController.addAction(quoteAction)
		alertController.addAction(cancelAction)
		if let popoverPresentationController = alertController.popoverPresentationController {
			popoverPresentationController.sourceView = controller.view
			popoverPresentationController.sourceRect = sender.convert(sender.bounds, to: controller.view)
		}
		controller.present(alertController, animated: true, completion: nil)
	}
	
	func tweetDetailsTap(at index: Int) {
		coordinator.showTweetDetails(tweet: tweets[index])
	}
	
	func refreshTweets() {
		interactor.loadTweets(nil) { [weak self] (tweetsResponse) in
			self?.controller.hideHUD()
			switch tweetsResponse {
			case .success(let tweets):
				self?.tweets = tweets
				let viewModel = FeedViewModel(tweets)
				self?.viewModel = viewModel
				self?.controller.setup(with: viewModel)
				self?.controller.stopPullToRefresh()
				self?.fetchSealsForTweets(tweets)
				self?.fetchUsersVerifiedStatus(tweets)
			case .failure(let error):
				self?.controller.showError(error)
				self?.controller.stopPullToRefresh()
			}
		}
	}
	
	func fetchSealsForTweets(_ tweets: [Tweet]) {
		interactor.loadSealsForTweets(tweets) { [weak self] result in
			switch result {
			case .success(let posts):
				let viewModel = self?.viewModel
				posts.forEach({ [weak self] post in
					guard let index = self?.tweets.index(where: { tweet -> Bool in
						tweet.id == post.id
					}) else { return }
                    self?.tweets[index].seal = post.seal
					self?.tweets[index].tweetReferenceId = post.tweetReferenceId ?? self?.tweets[index].tweetReferenceId
					viewModel?.update(with: post, at: index)
				})
				self?.controller.updateVisibleItems()
				break
			case .failure(let error):
				self?.controller.showError(error)
			}
		}
	}
	
	func loadNextTweets() {
		let lastTweet = self.tweets.last
		guard let tweet = lastTweet else {
			return
		}
		interactor.loadTweets(tweet) { [weak self] (tweetsResponse) in
			self?.controller.stopLoadingMore()
			switch tweetsResponse {
			case .success(let tweets):
				guard self?.viewModel != nil, !tweets.isEmpty else {
					return
				}
				self?.tweets.append(contentsOf: tweets)
                self?.controller.append(with: tweets)
				self?.fetchSealsForTweets(tweets)
				self?.fetchUsersVerifiedStatus(tweets)
			case .failure(let error):
				self?.controller.showError(error)
			}
		}
	}
	
	func fetchUsersVerifiedStatus(_ tweets: [Tweet]) {
		interactor.getUsersVerifiedStatusForTweets(tweets) { [weak self] result in
			switch result {
			case .success(let statuses):
				guard let strongSelf = self,
					let viewModel = strongSelf.viewModel else { return }
				var index = 0
				strongSelf.tweets.forEach({ tweet in
					let status = statuses.users.first(where: { tweet.tweetInfo.user.id == TwitterId($0.id) })
					viewModel.update(with: status?.verified ?? false, at: index)
					index += 1
				})
				self?.controller.updateVisibleItems()
			case .failure(let error):
				print(error)
			}
		}
	}
	
	func likeTap(at index: Int) {
		let tweet = tweets[index]
		interactor.changeLikeStatus(of: tweet, to: !tweet.isLiked) { [weak self] (result) in
			switch result {
			case .success(let isSuccess):
				guard let oldTweet = self?.tweets[index], isSuccess else { return }
				var tweet = oldTweet
				tweet.likesCount += tweet.isLiked ? -1 : 1
				tweet.isLiked = !tweet.isLiked
				self?.tweets[index] = tweet
				self?.viewModel?.update(with: tweet, at: index)
				self?.controller.updateTweetItem(at: index)
			case .failure(let error):
				self?.controller.showError(error)
			}
		}
	}
	
	func messageTap(at index: Int) {
		let tweet = tweets[index]
		coordinator.showDirectMessagesUserPicker (tweetToShare: tweet)
	}
	
	func hashtagTap(_ hashtag: String, at index: Int) {
		coordinator.showHashtagsSearch(withPreferedText: hashtag)
	}
	
	func mentionTap(_ mention: String, at index: Int) {
		let mentionedUsers = tweets[index].tweetInfo.mentionedUsers
		let filterClosure: ReturnClosure<MentionedUser, Bool> = { $0.screenName
			.lowercased()
			.contains(mention.lowercased()) }
		guard let mentionedUser = mentionedUsers.first(where: filterClosure) else { return }
		coordinator.showUserProfile(userId: mentionedUser.id, userScreenName: mentionedUser.screenName)
	}
	
	func linkTap(_ link: String, at index: Int) {
		guard let url = URL(string: link) else { return }
		interactor.openUrl(url)
	}
	
	func sealDidTap(at index: Int) {
        guard let dataSource = self.viewModel?.dataSource,
            case let FeedViewModel.DataSource.tweets(tweets) = dataSource else { return }
		coordinator.displaySealDetails(tweets[index])
	}
	
	func longTapAction(at index: Int, withSender sender: UIView) {
		let tweet = self.tweets[index]
		showMenuWithRelationsPreloading(for: tweet, fromView: sender)
	}
	
	func showSensitiveAction() {}
}
