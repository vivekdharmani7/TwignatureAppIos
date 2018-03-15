//
//  ProfileFlow.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/7/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

protocol CanShowChat: ConversationCoordinator {
	func showChat(for user: User, initialMessage: String?)
	func showChat(for chat: Conversation, initialMessage: String?)
}

protocol CanShowDirectMessages: DirectMessagePickerCoordinator {
	func showDirectMessagesUserPicker(tweetToShare: Tweet?)
}

extension CanShowChat {
	func showChat(for user: User, initialMessage: String?) {
		let conversation = Conversation(messages: [], user: user)
		showChat(for: conversation, initialMessage: initialMessage)
	}
	
	func showChat(for chat: Conversation, initialMessage: String?) {
		let vc = ConversationViewController()
		ConversationWireframe.setup(vc, withCoordinator: self) { presenter in
			presenter.conversation = chat
			presenter.initialMessage = initialMessage
		}
		
		router.show(vc)
	}
}

extension CanShowDirectMessages {
	func showDirectMessagesUserPicker(tweetToShare: Tweet?) {
		guard let vc = R.storyboard.directMessagePicker.directMessagePickerViewController() else {
			return
		}
		
		DirectMessagePickerWireframe.setup(vc, withCoordinator: self) { (presenter) in
			presenter.tweet = tweetToShare
		}
		
		router.present(vc)
	}
}

class ProfileFlow: BaseFlow, ProfileCoordinator, TweetDetailsCoordinator, MediaTweetsCoordinator {

}

extension ProfileCoordinator {
	func showTweets(for user: User, preloadedTweets: [Tweet]) {
		guard let vc = R.storyboard.tweetsForUser.tweetsForUserViewController() else {
			return
		}
		
		TweetsForUserWireframe.setup(vc, withCoordinator: self) { presenter in
			presenter.user = user
			presenter.setPreloadedTweets(tweets: preloadedTweets)
		}
		
		router.show(vc)
	}
    
    func showFavorites(user: User) {
        guard let vc = R.storyboard.tweetsForUser.tweetsForUserViewController() else {
            return
        }
        UserLikesWireframe.setup(vc, withCoordinator: self) { presenter in
            presenter.user = user
        }
        router.show(vc)
    }
    
    func showFollowers(user: User) {
        guard let vc = R.storyboard.profile.userListViewController() else {
            return
        }
        UserListWireframe.setup(vc, withCoordinator: self) { presenter in
            presenter.title = R.string.profile.followers()
			presenter.textForNodata = R.string.profile.noFollowers()
            presenter.user = user
            presenter.configure(endpoint: .followers)
        }
        router.show(vc)
    }
    
    func showFollowing(user: User, hidesUnfollowButton: Bool) {
        guard let vc = R.storyboard.profile.userListViewController() else {
            return
        }
        UserListWireframe.setup(vc, withCoordinator: self) { presenter in
            presenter.title = R.string.profile.following()
			presenter.textForNodata = R.string.profile.noFollowing()
            presenter.user = user
            presenter.configure(endpoint: .friends, hidesCellButton: hidesUnfollowButton)
        }
        router.show(vc)
    }
	
	func showMentions(user: User) {
		let mentionsController = R.storyboard.tweetsForUser.tweetsForUserViewController()!
		UserMentionsWireframe.setup(mentionsController,
		                            withCoordinator: self) { (presenter) in
			presenter.user = user
		}
		router.show(mentionsController)
	}
}
