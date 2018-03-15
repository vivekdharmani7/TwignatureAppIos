//
//  SealDetailsViewModel.swift
//  Twignature
//
//  Created by mac on 10.10.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class SealDetailsViewModel {

	let authorName: String
	let authorTweeterName: String
	let authorAvatarUrl: URL?
	
	var seal: Seal?
	// only one of this two is required, and extended media have more high priority
	let extendedMedia: [MediaItem]?
	let signatureImage: UIImage?
	
	let createdAt: Date
	let signId: String
	let locationFullName: String?
	
	init(withTweetViewModel tweetModel: FeedViewModel.TweetViewItem) {
		authorName = tweetModel.authorName
		authorTweeterName = tweetModel.tweetInfo.user.name
		authorAvatarUrl = tweetModel.tweetInfo.user.profileImageUrl
		seal = tweetModel.seal
		extendedMedia = tweetModel.extendedMedia
		signatureImage = nil
		createdAt = tweetModel.createdAt
		signId = tweetModel.tweetReferenceId ?? ""
		locationFullName = tweetModel.locationFullName
	}
	
	init(withSeal seal: Seal,
	     user: User,
	     withSignatureImage: UIImage,
	     createdAt: Date,
	     withSignId: String,
	     locationFullName: String?) {
		authorName = user.name
		authorTweeterName = user.screenName
		authorAvatarUrl = user.profileImageUrl
		signatureImage = withSignatureImage
		extendedMedia = nil
		self.createdAt = createdAt
		signId = withSignId
		self.seal = seal
		self.locationFullName = locationFullName
	}
}
