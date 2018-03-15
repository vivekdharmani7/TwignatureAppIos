//
//  ProfileProtocols.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/6/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

protocol ProfileCoordinator: TweetsForUserCoordinator, MediaTweetsCoordinator {
	func showTweets(for user: User, preloadedTweets: [Tweet])
    func showFavorites(user: User)
    func showFollowers(user: User)
    func showFollowing(user: User, hidesUnfollowButton: Bool)
	func showMentions(user: User)
}
