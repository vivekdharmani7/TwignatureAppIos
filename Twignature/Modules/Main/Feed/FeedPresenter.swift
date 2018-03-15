//
//  FeedPresenter.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/4/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit
import TwitterKit

extension FeedPresenter: CanShowTweetMenu {
	var menuInteractor: TweetsInteractor {
		return interactor
	}
	
	var viewController: UIViewController {
		guard let viewController = controller as? UIViewController else {
			fatalError("controller is not inherited from UIViewController")
		}
		return viewController
	}
}

class FeedPresenter {
	
    private var tweets: [Tweet] = []
    private var users: [User] = []
    private weak var viewModel: FeedViewModel?
    
    fileprivate let coordinator: FeedCoordinator
    unowned var controller: FeedControllerProtocol
    var interactor: FeedInteractor
    
    // MARK: - Init
    
    init(controller: FeedControllerProtocol,
                  interactor: FeedInteractor,
                  coordinator: FeedCoordinator) {
        self.controller = controller
        self.coordinator = coordinator
        self.interactor = interactor
		NotificationCenter.default.addObserver(self,
		                                       selector: #selector(feedShouldBeReloaded),
		                                       name: NSNotification.Name(rawValue:
												NotificationIdentifier.FeedShouldReload), object: nil)
	    self.controller.setNewPostButton(UserDefaults.standard.bool(forKey: Key.isPowerPanPurchasedKey))
	}

	func viewIsOnScreen() {
		self.controller.setNewPostButton(UserDefaults.standard.bool(forKey: Key.isPowerPanPurchasedKey))
	}
	
	@objc
	private func feedShouldBeReloaded() {
		guard isViewReady else {
			return
		}
		refreshTweets()
	}
    
    // Mark: - Interactor events handling
    
    func didReload(tweets: [Tweet]) {
        self.tweets = tweets
        self.viewModel?.set(tweets: tweets)
        self.controller.setup(with: viewModel!)
        self.controller.stopPullToRefresh()
        self.fetchSealsForTweets(tweets)
		fetchUsersVerifiedStatus(tweets)
    }
    
    func didLoadMore(tweets: [Tweet]) {
        self.tweets += tweets
        controller.append(with: tweets)
        fetchSealsForTweets(tweets)
		fetchUsersVerifiedStatus(tweets)
    }
    
    func didReload(users: [User]) {
        self.users = users
        self.viewModel?.set(users: users)
        self.controller.setup(with: viewModel!)
        self.controller.stopPullToRefresh()
    }
    
    func didLoadMore(users: [User]) {
        self.users += users
        viewModel?.append(users: users)
        controller.setup(with: viewModel!)
		fetchUsersVerifiedStatus(tweets)
    }
    
    func didFail(error: Error) {
        controller.stopLoadingMore()
        controller.stopPullToRefresh()
        viewController.hideHUD()
        viewController.showError(error)
    }
    
    // MARK: - View events handling
	
	private var isViewReady = false
	
    func viewIsReady() {
		let viewModel = FeedViewModel()
		self.viewModel = viewModel
		UserDefaults.standard.set(true, forKey: Key.onBoardingPressented)
		controller.setup(with: viewModel)
		refreshTweets()
		interactor.updateTwitterConfiguration()
		isViewReady = true
    }
    
    func replyTap(at index: Int) {
		let tweet = self.tweets[index]
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
			selectedUser = tweet.retweetInfo?.user
		}
		coordinator.showUserProfile(userId: selectedUser.id, userScreenName: selectedUser.screenName)
	}
	
	func sealDidTap(at index: Int) {
        guard let dataSource = self.viewModel?.dataSource,
            case let FeedViewModel.DataSource.tweets(tweets) = dataSource else { return }
		coordinator.displaySealDetails(tweets[index])
	}
	
    func handleFilterChange(filter: FeedViewModel.SearchFilter) {
        interactor.performSearch(filter: filter)
    }
    
    func handleSearchInput(query: String?, filter: FeedViewModel.SearchFilter) {
        if let query = query, !query.isEmpty {
            if viewModel?.isSearchActive != true {
                controller.updateView(isSearchEnabled: true)
                viewModel?.isSearchActive = true
            }
            let regularExpressionString = "^.*([[:alnum:]])+"
            do {
                let regex = try NSRegularExpression(pattern: regularExpressionString)
                let results = regex.matches(in: query,
                                            range: NSRange(query.startIndex..., in: query))
                if results.isEmpty {
                    print("error")
                } else {
                    interactor.performSearch(query: query, filter: filter)
                }
            } catch let error {
                print("invalid regex: \(error.localizedDescription)")
            }
        } else {
            viewModel?.isSearchActive = false
            controller.updateView(isSearchEnabled: false)
            finishSearch()
        }
    }
    
    func retweetTap(at index: Int, withSender sender: UIView) {
		let tweet = self.tweets[index]
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
		if let popoverPresentationController = alertController.popoverPresentationController {
			popoverPresentationController.sourceView = self.viewController.view
			popoverPresentationController.sourceRect = sender.convert(sender.bounds, to: self.viewController.view)
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
//					R.string.tweets.tweetRetweetedSuccessfully())
				case .failure(let error):
					self?.viewController.showError(error)
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
			popoverPresentationController.sourceView = viewController.view
			popoverPresentationController.sourceRect = sender.convert(sender.bounds, to: viewController.view)
		}
		viewController.present(alertController, animated: true, completion: nil)
    }
	
	func tweetDetailsTap(at index: Int) {
		coordinator.showTweetDetails(tweet: tweets[index])
	}
	
    func userTap(at index: Int) {
        coordinator.showUserProfile(userId: users[index].id, userScreenName: users[index].screenName)
    }
    
	func refreshTweets() {
        interactor.loadTweets()
	}
    
    func finishSearch() {
        interactor.resetSearch()
        interactor.loadTweets()
        viewModel?.isSearchActive = false
        controller.updateView(isSearchEnabled: false)
    }
	
	func fetchSealsForTweets(_ tweets: [Tweet]) {
        guard !tweets.isEmpty else { return }
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
			case .failure(let error):
				self?.viewController.showError(error)
			}
		}
	}
	
	func fetchUsersVerifiedStatus(_ tweets: [Tweet]) {
        guard !tweets.isEmpty else { return }
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

	func loadNextItems() {
        if let viewModel = viewModel, viewModel.isSearchActive {
            interactor.loadMoreData()
        } else {
            interactor.loadMoreTweets()
        }
	}
	
    func likeTap(at index: Int) {
        let tweet = tweets[index]
		let viewModel = self.viewModel
        interactor.changeLikeStatus(of: tweet, to: !tweet.isLiked) { [weak self, weak viewModel] (result) in
            switch result {
            case .success(let isSuccess):
                guard let oldTweet = self?.tweets[index], isSuccess, let requiredViewModel = viewModel else { return }
                var tweet = oldTweet
                tweet.likesCount += tweet.isLiked ? -1 : 1
                tweet.isLiked = !tweet.isLiked
                self?.tweets[index] = tweet
                requiredViewModel.update(with: tweet, at: index)
                self?.controller.updateTweetItem(at: index)
            case .failure(let error):
                if let twignatureError = error as? TwignatureError {
                    switch twignatureError {
                    case .twitterError( _, let code):
                        if code == 144 { return }
                    default: break
                    }
                }
                self?.viewController.showError(error)
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
    
    func createTweetTap() {
		coordinator.showCreateTweet { [weak self] _ in
			self?.controller.startPullToRefresh()
			self?.controller.scrollToTop()
			self?.refreshTweets()
		}
    }
	
	func longTapAction(at index: Int, withSender sender: UIView) {
		let tweet = self.tweets[index]
		showMenuWithRelationsPreloading(for: tweet, fromView: sender)
	}
	
	func showSensitiveAction() { }	
}
