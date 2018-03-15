//
//  MediaDatasource.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/11/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

class MediaTweetsDataSource {
	let tweets: [Tweet]
	private(set) var mediaItems: [MediaItem]
	let mediaToTweetsMap: [Int: Int]
	
	func tweetForMedia(at index: Int) -> Tweet? {
		guard let tweetIndex = mediaToTweetsMap[index] else {
			return nil
		}
		return tweets[tweetIndex]
	}
	
	var count: Int {
		return mediaToTweetsMap.count
	}
	
	init(tweets: [Tweet]) {
		let mediaTweets = tweets.filter { return $0.tweetInfo.extendedMedia != nil }
		var mediaIndex = 0
		var mediaToTweetsMap = [Int: Int]()
		var mediaItems = [MediaItem]()
		for tweetIndex in mediaTweets.indices {
			let tweet = mediaTweets[tweetIndex]
			let nextItems = tweet.tweetInfo.extendedMedia!
			for _ in nextItems {
				mediaToTweetsMap[mediaIndex] = tweetIndex
				mediaIndex += 1
			}
			mediaItems.append(contentsOf: nextItems)
		}
		self.tweets = mediaTweets
		self.mediaItems = mediaItems
		self.mediaToTweetsMap = mediaToTweetsMap
	}
}
