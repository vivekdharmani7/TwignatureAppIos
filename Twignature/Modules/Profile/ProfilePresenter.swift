//
//  ProfilePresenter.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/6/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

extension ProfilePresenter: CanShowUserMenu {
	var userInteractor: UserInteractor {
		return interactor
	}
	
	var viewController: UIViewController {
		return controller
	}
}

class ProfilePresenter {
	fileprivate var user: User? {
		didSet {
			controller.availableForFriendship = availableForFriendship
		}
	}
	
	private var availableForFriendship: Bool {
		guard let user = user, let currentUser = Session.current?.user else {
			return false
		}
		
		return user != currentUser
	}
	
    fileprivate let coordinator: ProfileCoordinator
    fileprivate unowned var controller: ProfileViewController
    fileprivate var interactor: ProfileInteractor
	fileprivate var tweets: [Tweet]?
	
    var userId: String!
    var userScreenName: String!
    
    required init(controller: ProfileViewController,
                  interactor: ProfileInteractor,
                  coordinator: ProfileCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
    }
	
	func profileLinkAction() {
		guard let expandedUrl = user?.expandedUrl else {
			return
		}
		interactor.openUrl(expandedUrl)
	}
	
	func mediaAction(mediaItem: MediaItem) {
		guard let tweets = tweets else {
			return
		}
		
		coordinator.showMediaTweets(tweets: tweets, initialMediaItem: mediaItem)
	}
	
    // MARK: - View events handling
    
    func viewIsReady() {
		controller.isCloseEnabled = coordinator.router.canDissmiss
		controller.availableForFriendship = false
		controller.isFollowing = false
        interactor.loadUserDetails(userId: userId, screenName: userScreenName) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let user):
                guard let details = user.details else { fatalError("Details not found") }
                strongSelf.controller.configure(header: ProfileViewController.HeaderViewModel(user: user))
                strongSelf.interactor.loadMedia(userId: strongSelf.userId, completion: { [weak strongSelf] result in
                    switch result {
                    case .success(let mediaTweets):
						strongSelf?.tweets = mediaTweets.allTweets
                        strongSelf?
							.controller
							.configure(details: ProfileViewController.Details(details: details), media: mediaTweets.mediaItems)
                    case .failure(let error):
                        if let twignatureError = error as? TwignatureError {
                            switch twignatureError {
                            case .twitterError(_, let code):
                                if code == 136 {
									let headerViewModel = ProfileViewController.HeaderViewModel(user: user)
									strongSelf?.controller.setToBlockedState(header: headerViewModel)
                                    return
                                }
                            default: break
                            }
						}
                        strongSelf?.controller.showError(error)
                    }
                })
				strongSelf.user = user
				strongSelf.getRelations()
            case .failure(let error):
                strongSelf.controller.showError(error)
            }
        }
    }
	
	func optionsAction(_ sender: UIView) {
		guard let user = user else {
			return
		}
		showMenu(for: user, withSender: sender)
	}
	
	private func getRelations() {
		guard availableForFriendship else { return }
		guard let user = user else { return }
		
		interactor.getRelationsFor(user: user) { [weak self] result in
			switch result {
			case .success(let relation):
				self?.relationshipWithUser = relation
			case .failure(let error):
				print(error.localizedDescription)
                self?.controller.showError(error)
//                self?.showNotFollowerWarning(user)
			}
		}
	}
	
    func closeTap() {
        coordinator.dismiss()
    }
	
	func directMessageAction() {
		guard let user = user else {
			return
		}
		
		if user == Session.current?.user {
			coordinator.showDirectMessagesUserPicker(tweetToShare: nil)
		} else {
			showChatIfPossible(user: user)
		}
	}
	
	func showTweetsAction() {
		guard let user = user else { return }
		coordinator.showTweets(for: user, preloadedTweets: tweets ?? [])
	}
    
    func showLikesAction() {
        guard let user = user else { return }
        coordinator.showFavorites(user: user)
    }
    
    func showFollowersAction() {
        guard let user = user else { return }
        coordinator.showFollowers(user: user)
    }
    
    func showFollowingAction() {
        guard let user = user else { return }
        coordinator.showFollowing(user: user, hidesUnfollowButton: Session.current?.user.id != user.id)
    }
	
	func showMentionsAction() {
		guard let user = user else { return }
		coordinator.showMentions(user: user)
	}
	
	func togglefollowAction(_ sender: UIView) {
		guard let user = user,
			let isFollowing = relationshipWithUser?.isFollowing else {
				return
		}
		
		let completion = { [weak self] (result: Result<Bool>) in
			switch result {
			case .success:
				self?.relationshipWithUser?.isFollowing = !isFollowing
			case .failure(let error):
				self?.controller.showError(error)
			}
		}

		if isFollowing {
			unfollowWithWarning(user, withSender: sender, completion: completion)
		} else {
			interactor.followUser(user, completion: completion)
		}
	}
	
	private var relationshipWithUser: RelationshipWithUser? {
		didSet {
			guard let relationshipWithUser = relationshipWithUser else {
				return
			}
			
			controller.isFollowing = relationshipWithUser.isFollowing
		}
	}
	
	private func showChatIfPossible(user: User) {
		if let relationshipWithUser = relationshipWithUser {
			tryShowDirectMessages(user: user, isFollower: relationshipWithUser.isFollowedBy)
			return
		}
		
		interactor.getRelationsFor(user: user) { [weak self] result in
			switch result {
			case .success(let relation):
				self?.relationshipWithUser = relation
				self?.tryShowDirectMessages(user: user, isFollower: relation.isFollowedBy)
			case .failure(let error):
				print(error.localizedDescription)
                self?.controller.showError(error)
//                self?.showNotFollowerWarning(user)
			}
		}
	}
	
	private func tryShowDirectMessages(user: User, isFollower: Bool) {
		if isFollower {
			coordinator.showChat(for: user, initialMessage: nil)
		} else {
			showNotFollowerWarning(user)
		}
	}
	
	private func showNotFollowerWarning(_ user: User) {
		let alertController = UIAlertController(title: "Not followed",
		                                        message: R.string.twignatureError.notFollowedByYouWarning(),
		                                        preferredStyle: UIAlertControllerStyle.alert)
		let yesAction = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
			self?.coordinator.showChat(for: user, initialMessage: nil)
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
		alertController.addAction(cancelAction)
        alertController.addAction(yesAction)
		
		controller.present(alertController, animated: true, completion: nil)
	}
	
	private func unfollowWithWarning(_ user: User, withSender sender: UIView, completion: @escaping ResultClosure<Bool>) {
		let message = "\(R.string.profile.unfollowWarning()) @\(user.screenName)?"
		let alertController = UIAlertController(title: nil,
		                                        message: message,
		                                        preferredStyle: UIAlertControllerStyle.actionSheet)
		let yesAction = UIAlertAction(title: "Unfollow", style: .destructive) { [weak self] _ in
			self?.interactor.unFollowUser(user, completion: completion)
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
			self?.relationshipWithUser?.isFollowing = true
		}
		alertController.addAction(yesAction)
		alertController.addAction(cancelAction)
		if let popoverPresentationController = alertController.popoverPresentationController {
			popoverPresentationController.sourceView = controller.view
			popoverPresentationController.sourceRect = sender.convert(sender.bounds, to: controller.view)
		}
		controller.present(alertController, animated: true, completion: nil)
	}
}
