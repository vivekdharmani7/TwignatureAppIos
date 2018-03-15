//
//  MediaTweetsPresenter.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/9/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class MediaTweetsPresenter {
	
	var initialMediaItem: MediaItem?
	var tweets = [Tweet]()
	
    //MARK: - Init
    required init(controller: MediaTweetsViewController,
                  interactor: MediaTweetsInteractor,
                  coordinator: MediaTweetsCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
    }
    
    //MARK: - Private -
    fileprivate let coordinator: MediaTweetsCoordinator
    fileprivate unowned var controller: MediaTweetsViewController
    fileprivate var interactor: MediaTweetsInteractor
	
	func viewIsReady() {
		let source = MediaTweetsDataSource(tweets: tweets)
		let optIX = source.mediaItems.index(where: { $0.mediaUrl == initialMediaItem?.mediaUrl })
		let initialItemIndex = optIX ?? 0

		controller.configureWith(source, initialItemIndex: initialItemIndex)
	}
	
	func closeAction() {
		coordinator.dismiss()
	}
	
	func hashtagAction(_ hashtag: String) {
		print("hashtagAction \(hashtag) not implemented")
	}
	
	func mentionAction(_ userName: String) {
		let users = tweets.flatMap { $0.tweetInfo.mentionedUsers }
		
		guard let user: MentionedUser = users.first(where: { $0.screenName == userName }) else {
			return
		}
	
		coordinator.showUserProfile(userId: user.id, userScreenName: userName)
	}
	
	func linkAction(_ url: URL) {
		interactor.openUrl(url)
	}
}
