//
//  CanShowTweetMenu.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/12/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import TwitterCore

protocol MenuCommon: class {
	var viewController: UIViewController { get }
	var userInteractor: UserInteractor { get }
}

protocol CanShowTweetMenu: MenuCommon {
	var viewController: UIViewController { get }
	var menuInteractor: TweetsInteractor { get }
	
	func showMenuWithRelationsPreloading(for tweet: Tweet, fromView: UIView)
	func showMenu(for tweet: Tweet, relationshipWithUser: RelationshipWithUser?, fromView: UIView)
}

extension CanShowTweetMenu {
	var userInteractor: UserInteractor { return  menuInteractor }
}

protocol CanShowUserMenu: MenuCommon {
	var viewController: UIViewController { get }
	
	func showMenu(for user: User, withSender sender: UIView)
}

extension MenuCommon {
	fileprivate func createBoolCompletion(text: String? = nil, reloadFeed: Bool = false) -> ResultClosure<Bool> {
		let completion: ResultClosure<Bool> = { [weak self] result in
			switch result {
			case .success:
				if reloadFeed {
					let notificationName = NSNotification.Name(rawValue: NotificationIdentifier.FeedShouldReload)
					NotificationCenter.default.post(name: notificationName, object: nil)
				}
				self?.viewController.showAlert(with: text ?? "Operation has been succeeded")
			case .failure(let error):
				if let twignatureError = error as? TwignatureError {
					switch twignatureError {
					case .twitterError( _, let code):
						if code == 144 {
							if reloadFeed {
								let notificationName = NSNotification.Name(rawValue: NotificationIdentifier.FeedShouldReload)
								NotificationCenter.default.post(name: notificationName, object: nil)
							}
							self?.viewController.showAlert(with: text ?? "Operation has been succeeded")
							return
						}
					default: break
					}
				}
				print(error.localizedDescription)
				self?.viewController.showError(error)
			}
		}
		
		return completion
	}
	
	fileprivate func getComplainUserAction(user: User) -> UIAlertAction {
		return UIAlertAction(title: "Report spam", style: .default) { [unowned self] _ in
			self.userInteractor.complainUser(user, completion: self.createBoolCompletion(reloadFeed: true))
		}
	}
	
	fileprivate func getAddUserToBlacklistAction(user: User) -> UIAlertAction {
		let screenName = user.screenName
		return UIAlertAction(title: "Add @\(screenName) to blacklist", style: .default) { [unowned self] _ in
			self.viewController.showAgreeAlert(with: "Do you really want to blacklist the user?", agreeBlock: { [weak self] () in
				let text = "@\(screenName) was added to blacklist"
				guard let completion = self?.createBoolCompletion(text: text, reloadFeed: true) else { return }
				self?.userInteractor.blockUser(user, completion: completion)
			})
		}
	}
	
	fileprivate func getIgnoreUserAction(user: User) -> UIAlertAction {
		let screenName = user.screenName
		return UIAlertAction(title: "Ignore @\(screenName)", style: .default) { [unowned self] _ in
			self.viewController.showAgreeAlert(with: "Do you really want to ignore the user?", agreeBlock: { [weak self] () in
				guard let completion = self?.createBoolCompletion(text: "@\(screenName) will be ignored", reloadFeed: true) else { return }
				self?.userInteractor.muteUser(user, completion: completion)
			})
		}
	}
	
}

extension CanShowTweetMenu {
	
	func showMenuWithRelationsPreloading(for tweet: Tweet, fromView: UIView) {
		guard Session.current?.user != tweet.tweetInfo.user else {
			showMenu(for: tweet, relationshipWithUser: nil, fromView: fromView)
			return
		}
		
		self.menuInteractor.getRelationsFor(user: tweet.tweetInfo.user) { [weak self] result in
			var relationsWithUser: RelationshipWithUser?
			switch result {
			case .success(let relations):
					relationsWithUser = relations
				case .failure(let error):
					debugPrint(error)
			}
			
			self?.showMenu(for: tweet, relationshipWithUser: relationsWithUser, fromView: fromView)
		}
	}
	
	func showMenu(for tweet: Tweet, relationshipWithUser: RelationshipWithUser?, fromView: UIView) {
		let user = tweet.tweetInfo.user
		let screenName = user.screenName
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
		let isCurrentUser = Session.current?.user == tweet.tweetInfo.user

		let shareAction = UIAlertAction(title: "Share tweet", style: .default) { [weak self] _ in
			self?.shareTweet(tweet)
		}
		alertController.addAction(shareAction)
		let copyAction = UIAlertAction(title: "Copy tweet link", style: .default) { _ in
			UIPasteboard.general.string = tweet.shareURL
		}
		alertController.addAction(copyAction)
		
		if isCurrentUser {
			let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] _ in
				self.viewController.showAgreeAlert(with: "Do you really want to delete the tweet?", agreeBlock: { [weak self] () in
					guard let completion = self?.createBoolCompletion(text: "Tweet has been deleted", reloadFeed: true) else { return }
					self?.menuInteractor.deleteTweet(tweetId: tweet.id,
					                                 completion: completion)
				})
			}
			alertController.addAction(deleteAction)
		} else {
			let isFollowing = relationshipWithUser?.isFollowing ?? false
			let followActionTitle = isFollowing ? "Unfollow" : "Follow"
			let followUserAction = UIAlertAction(title: "\(followActionTitle) @\(screenName)", style: .default) { [unowned self] _ in
				if isFollowing {
					self.menuInteractor.unFollowUser(user, completion: self.createBoolCompletion(reloadFeed: true))
				} else {
					self.menuInteractor.followUser(user, completion: self.createBoolCompletion(reloadFeed: true))
				}
			}		
			
			alertController.addAction(followUserAction)
			alertController.addAction(getIgnoreUserAction(user: user))
			alertController.addAction(getAddUserToBlacklistAction(user: user))
			alertController.addAction(getComplainUserAction(user: user))
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
		alertController.addAction(cancelAction)
		if let popoverPresentationController = alertController.popoverPresentationController {
			popoverPresentationController.sourceView = viewController.view
			popoverPresentationController.sourceRect = fromView.convert(fromView.bounds, to: viewController.view)
		}
		viewController.present(alertController, animated: true, completion: nil)
	}
	
	private func shareTweet(_ tweet: Tweet) {
		let objectsToShare = [tweet.tweetInfo.text, tweet.shareURL] as [Any]
		let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
		
		activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
		
		activityVC.popoverPresentationController?.sourceView = viewController.view
		viewController.present(activityVC, animated: true, completion: nil)
	}
}

extension CanShowUserMenu {
	func showMenu(for user: User, withSender sender: UIView) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }

		alertController.addAction(getIgnoreUserAction(user: user))
		alertController.addAction(getAddUserToBlacklistAction(user: user))
		alertController.addAction(getComplainUserAction(user: user))
		alertController.addAction(cancelAction)
		
		if let popoverPresentationController = alertController.popoverPresentationController {
			popoverPresentationController.sourceView = viewController.view
			popoverPresentationController.sourceRect = sender.convert(sender.bounds, to: viewController.view)
		}
		
		viewController.present(alertController, animated: true, completion: nil)
	}
}
