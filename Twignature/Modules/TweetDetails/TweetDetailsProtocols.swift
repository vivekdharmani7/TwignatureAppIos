//
//  TweetDetailsProtocols.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/18/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

protocol TweetDetailsCoordinator: CreateTweetCoordinator, CanShowUserProfile, CanShowDirectMessages, SealDetailsCoordinator, CanShowHashtagSearch {
}

typealias TweetID = TwitterId

protocol TweetUserInteractive: class {
	func replyAction(tweet : Tweet)
	func retweetAction(tweet : Tweet, withSender sender: UIView)
	func likeAction(tweet : Tweet)
	func messageAction(tweet : Tweet)
    func sealAction(tweet : Tweet)
	func menuAction(tweet : Tweet, withSender sender: UIView)
	func mediaAction(item : MediaItem, transitionImageView: UIImageView?)
	func urlAction(url : URL)
	func hashTagAction(tag : String)
	func mentionAction(user : MentionedUser)
	func avatarAction(user : User)
	func showSensitiveAction()
}
