//
//  TweetDetailsPresenter.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/18/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

extension TweetDetailsPresenter: CanShowTweetMenu {
	var menuInteractor: TweetsInteractor {
		return interactor
	}
	
	var viewController: UIViewController {
		return controller
	}
}

class TweetDetailsPresenter {
    
    //MARK: - Init
    required init(controller: TweetDetailsViewController,
                  interactor: TweetDetailsInteractor,
                  coordinator: TweetDetailsCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
    }
    
    //MARK: - Private -
    fileprivate let coordinator: TweetDetailsCoordinator
    fileprivate unowned var controller: TweetDetailsViewController
    fileprivate var interactor: TweetDetailsInteractor
	
	func viewDidReady() {
		controller.inprogess = true
		controller.tweet = interactor.tweet
		controller.isMoreRepliesEnabled = false
		reloadAction()
	}
	
	func backAction() {
		coordinator.back()
	}
	
	func moreRepliesAction() {
		controller.inprogess = true
		interactor.fetchMoreReplies { [weak self] (result) in
			self?.processRepliesResult(result: result, reload: false)
		}
	}
	
	func reloadAction() {
		controller.inprogess = true
		interactor.fetchRepliesFromScretch { [weak self] (result) in
			self?.processRepliesResult(result: result, reload: true)
		}
	}
	
	func addReplyAction() {
		coordinator.showCreateTweet(inReplyTo: interactor.tweet) { [weak self] _ in
			self?.reloadAction()
		}
	}
	
	private func processRepliesResult(result: Result<[Tweet]>, reload: Bool) {
		controller.inprogess = false
		switch result {
		case .success(let newReplies):
			controller.updateReplies(replies: newReplies, reload: reload)
            fetchSealsForTweets(newReplies)
			controller.isMoreRepliesEnabled = interactor.hasMoreReplies
		case .failure(let error):
			controller.showError(error)
		}
	}
	
	func likeAction(tweet: Tweet) {
		interactor.changeLikeStatus(of: tweet, to: !tweet.isLiked) { [weak self] (result) in
			switch result {
			case .success(let isSuccess):
				guard isSuccess else { return }
				var updatedTweet = tweet
				updatedTweet.likesCount += tweet.isLiked ? -1 : 1
				updatedTweet.likesCount = updatedTweet.likesCount >= 0 ? updatedTweet.likesCount : 0
				updatedTweet.isLiked = !tweet.isLiked
				self?.controller.updateTweet(updated: updatedTweet)
			case .failure(let error):
				self?.controller.showError(error)
			}
		}
	}
	
	func retweetAction(tweet: Tweet, withSender sender: UIView) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
		let nativeAction = UIAlertAction(title: R.string.tweets.retweet(), style: .default) { [weak self] _ in
			self?.interactor.retweet(tweet) { [weak self] result in
				switch result {
				case .success:
					var newTweet = tweet
					newTweet.retweetCount += 1
					newTweet.isRetweeted = true
					self?.controller.updateTweet(updated: newTweet)
//					self?.controller.showAlert(with: R.string.tweets.tweetRetweetedSuccessfully())
				case .failure(let error):
					self?.controller.showError(error)
				}
			}
		}
		let quoteAction = UIAlertAction(title: R.string.tweets.quote(), style: .default) { [weak self] _ in
			self?.coordinator.showCreateTweet(asQuoteTo: tweet, withCompletion: { [weak self] _ in
				self?.reloadAction()
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
	
	func messageAction(tweet: Tweet) {
		coordinator.showDirectMessagesUserPicker(tweetToShare: tweet)
	}
    
    func sealAction(tweet: Tweet) {
        coordinator.displaySealDetails(FeedViewModel.TweetViewItem(tweet: tweet))
    }
	
	func hashtagAction(_ hashtag: String) {
		coordinator.showHashtagsSearch(withPreferedText: hashtag)
	}
	
	func mentionAction(_ user: MentionedUser) {
		coordinator.showUserProfile(userId: user.id, userScreenName: user.screenName)
	}
	
	func linkAction(_ url: URL) {
		interactor.openUrl(url)
	}
	
	func userAction(user: User) {
		coordinator.showUserProfile(userId: user.id, userScreenName: user.screenName)
	}
	
	func selectReplyAction(tweet: Tweet) {
		coordinator.showTweetDetails(tweet: tweet)
	}
	
	func headerAddReplyAction(_ reply: Tweet) {
		addReplyAction()
	}
	
	func menuAction(tweet: Tweet, withSender sender: UIView) {
		showMenuWithRelationsPreloading(for: tweet, fromView: sender)
	}
	
	func showSensitiveAction() {
		openTwitterSettings()
	}
	
	private func openTwitterSettings() {
		guard let url = URL(string: Links.twitterSafetySettings) else { return }
		interactor.openUrl(url)
	}
	
    func fetchSealsForTweets(_ tweets: [Tweet]) {
        interactor.loadSealsForTweets(tweets) { [weak controller] result in
            switch result {
            case .success(let posts):
                posts.forEach({ post in
                    guard let index = controller?.repliesViewModels.index(where: { tweet -> Bool in
                        tweet.id == post.id
                    }) else { return }
                    controller?.update(with: post, at: index)
                })
                controller?.updateVisibleItems()
            case .failure(let error):
                controller?.showError(error)
            }
        }
    }
    
}
