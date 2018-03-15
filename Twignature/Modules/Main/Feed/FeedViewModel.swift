//
//  FeedViewModel.swift
//  Twignature
//
//  Created by Anton Muratov on 9/10/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class FeedViewModel {
    private(set) var cachedHeights: [Int : CGFloat] = [:] // is it still needed?
    var searchFilter: SearchFilter = .people
    var isSearchActive: Bool = false
    var dataSource: DataSource?
    
    init() {}
    
    init(_ tweets: [Tweet]) {
        set(tweets: tweets)
    }
    
    init(_ users: [User]) {
        set(users: users)
    }
    
    // MARK: - Actions
    
    func set(tweets: [Tweet]) {
        dataSource = .tweets(tweets.map({ TweetViewItem(tweet: $0) }))
    }
    
    func set(users: [User]) {
        dataSource = .users(users.map({ UserViewItem(user: $0) }))
    }
	
	func append(tweets: [Tweet]) {
        guard let dataSource = dataSource, case let DataSource.tweets(oldTweets) = dataSource else { return }
		let newTweets = tweets.map({ TweetViewItem(tweet: $0) })
		self.dataSource = .tweets(oldTweets + newTweets)
	}
    
    func append(users: [User]) {
        guard let dataSource = dataSource, case let DataSource.users(oldUsers) = dataSource else { return }
        let newUsers = users.map({ UserViewItem(user: $0) })
        self.dataSource = .users(oldUsers + newUsers)
    }
	
	func update(with post: Post, at index: Int) {
        guard let dataSource = dataSource, case var DataSource.tweets(tweets) = dataSource else { return }
		guard index < tweets.count else { return }
		tweets[index].seal = post.seal
		tweets[index].tweetReferenceId = post.tweetReferenceId ?? tweets[index].tweetReferenceId
        self.dataSource = .tweets(tweets)
	}
	
	func update(with isUserVerified: Bool, at index: Int) {
		guard let dataSource = dataSource, case var DataSource.tweets(tweets) = dataSource else { return }
		guard index < tweets.count else { return }
		tweets[index].tweetInfo.user.isVerified = tweets[index].tweetInfo.user.isVerified || isUserVerified
		self.dataSource = .tweets(tweets)
	}
	
    func update(with tweet: Tweet, at index: Int) {
        guard let dataSource = dataSource, case var DataSource.tweets(tweets) = dataSource else { return }
        guard index < tweets.count else { return }
        tweets[index] = TweetViewItem(tweet: tweet)
        self.dataSource = .tweets(tweets)
    }
    
    func addHeightToCache(_ height: CGFloat, at index: Int) {
        cachedHeights[index] = height
    }
    
    // MARK: - Nested entities
    
    enum SearchFilter: Int {
        case people, tweets
        
        var title: String {
            switch self {
            case .people:
                return R.string.tweets.people()
            case .tweets:
                return R.string.tweets.tweets()
            }
        }
    }
    
    enum DataSource {
        case users([UserViewItem])
        case tweets([TweetViewItem])
        
        var count: Int {
            switch self {
            case .users(let users):
                return users.count
            case .tweets(let tweets):
                return tweets.count
            }
        }
    }
    
    struct UserViewItem {
        let name: String
        let screenName: String
        let isVerified: Bool
        let avatarUrl: URL?
        
        init(user: User) {
            self.name = user.name
            self.screenName = "@\(user.screenName) "
            self.avatarUrl = user.profileImageUrl
            self.isVerified = user.isVerified
        }
    }

	struct TweetViewInfoItem {

	}

    struct TweetViewItem {
        let authorName: String
//        let authorTweeterName: String
//        let authorAvatarUrl: URL?
        let imageUrl: URL?
        let videoUrl: URL?
        let text: String
		let replyTo: String?
        let retweetsCount: String
        let likesCount: String
        let isLiked: Bool
//        var isUserVerified: Bool
        let isRetweeted: Bool
        let isVideo: Bool
		let locationFullName: String?
		let location: Location?
		let extendedMedia: [MediaItem]?
		var tweetReferenceId: String?
		var seal: Seal?
		let createdAt: Date
		let signId: String
		let originTweetId: String?
//		let coverPossiblySensitive: Bool

		var tweetInfo: TweetInfo
		let retweetInfo: TweetInfo?

        var hasMedia: Bool {
			guard let extendedMedia = self.extendedMedia, !extendedMedia.isEmpty else {
				return false
			}
            return true
        }
        
        init(tweet: Tweet) {
			tweetInfo = tweet.tweetInfo
			retweetInfo = tweet.retweetInfo

			createdAt = tweet.createdAt
            authorName = tweet.tweetInfo.user.name
//            isUserVerified = tweet.user.isVerified
//            authorTweeterName = "@\(tweet.user.screenName)"
//            authorAvatarUrl = tweet.user.profileImageUrl
			
            retweetsCount = "\(tweet.retweetCount)"
            likesCount = "\(tweet.likesCount)"
            isLiked = tweet.isLiked
            isRetweeted = tweet.isRetweeted
			signId = tweet.id
			originTweetId = tweet.originTweetId
            isVideo = tweet.tweetInfo.extendedMedia?.first?.type == .video
            imageUrl = tweet.tweetInfo.extendedMedia?.first?.mediaUrl
            videoUrl = tweet.tweetInfo.extendedMedia?
                .first(where: { $0.videoInfo != nil })?
                .videoInfo?
                .items
                .sorted(by: { ($0.bitrate ?? 0) > ($1.bitrate ?? 0) })
                .first(where: { $0.contentType == .videoMp4 })?
                .url
			extendedMedia = tweet.tweetInfo.extendedMedia
			locationFullName = tweet.place?.fullname
			tweetReferenceId = tweet.tweetReferenceId
			seal = tweet.seal
//			coverPossiblySensitive = tweet.shouldBeCovered
			if tweet.tweetInfo.inReplyToStatusId == nil {
				text = tweet.tweetInfo.text
				replyTo = nil
			} else {
				let textAndNames = tweet.tweetInfo.extractTextAndReplyTo()
				replyTo = "answered to \(textAndNames.replyToNames)"
				text = textAndNames.text
			}
			
			guard let lat = tweet.latitude, let long = tweet.longitude else {
				location = nil
				return
			}
			location = Location(lat, long)
        }
	}
}
