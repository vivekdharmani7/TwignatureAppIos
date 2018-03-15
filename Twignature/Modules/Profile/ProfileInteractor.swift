//
//  ProfileInteractor.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/6/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias MediaTweetsClosure = ResultClosure<MediaTweets>
struct MediaTweets {
	var allTweets: [Tweet]
	var mediaItems: [MediaItem]
}

fileprivate class MediaTweetsLoader {
	let maxRequestCount = 3
	let desiredMinMediaCount = 6
	let tweetsPerRequets = 15
	
	private var networkService: NetworkService
	private var timeLineTweets = [Tweet]()
	private var requestCount = 0
	private var mediaItems = [MediaItem]()
	
	init(networkService: NetworkService) {
		self.networkService = networkService
	}
	
	func loadMediaTweets(userId: String, completion: @escaping MediaTweetsClosure) {
		timeLineTweets = []
		mediaItems = []
		requestCount = 0
		loadMediaHelper(userId: userId, lastId: nil, completion: completion)
	}
	
	private func loadMediaHelper(userId: TwitterId,
	                             lastId: TweetID?,
	                             completion: @escaping MediaTweetsClosure) {
		requestCount += 1
        self.loadTweets(userId: userId, lastId: lastId) { [weak self] result in
            switch result {
            case .success(let tweets):
                self?.tweetsDidLoad(userId: userId, tweets: tweets, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
	}
    
    private func loadTweets(userId: TwitterId,
                    lastId: TweetID?,
                    completion: @escaping ResultClosure<[Tweet]>) {
        let request = Request.Tweets.Timeline(userId: userId, lastId: lastId, count: tweetsPerRequets)
        let otherCompletion = networkService.filteringArrayTweetsClosure(completion: completion)
        networkService.fetchArray(resource: request, completion: otherCompletion)
    }
	
	private func tweetsDidLoad(userId: TwitterId, tweets: [Tweet], completion: @escaping MediaTweetsClosure) {
		guard !tweets.isEmpty else {
			let mediaTweets = MediaTweets(allTweets: timeLineTweets, mediaItems: mediaItems)
			completion(.success(mediaTweets))
			return
		}
		
		let shouldDisplaySensetiveContent = Session.current?.user.shouldDisplaySensetiveContent ?? false
		let tweetsForMedia: [Tweet]
		if shouldDisplaySensetiveContent {
			tweetsForMedia = tweets
		} else {
			tweetsForMedia = tweets.filter { tweet -> Bool in
				return !tweet.shouldBeCovered
			}
		}
		
		timeLineTweets.append(contentsOf: tweets)
		let newItems = tweetsForMedia.flatMap { return $0.tweetInfo.extendedMedia }
			.flatMap { $0 }
		
		mediaItems.append(contentsOf: newItems)
		if mediaItems.count >= desiredMinMediaCount || requestCount >= maxRequestCount {
			let mediaTweets = MediaTweets(allTweets: timeLineTweets, mediaItems: mediaItems)
			completion(.success(mediaTweets))
			return
		}
		loadMediaHelper(userId: userId, lastId: timeLineTweets.last?.id.prevId, completion: completion)
	}
	
}

class ProfileInteractor: BaseInteractor, UserInteractor {
    weak var presenter: ProfilePresenter!
	
	func loadUserDetails(userId: String,
                         screenName: String,
                         completion: @escaping ResultClosure<User>) {
        let request = Request.Users.Details(userId: userId, screenName: screenName)
        networkService.fetch(resource: request, completion: completion)
    }

    func loadMedia(userId: String, completion: @escaping MediaTweetsClosure) {
		var mediaTweetsLoader: MediaTweetsLoader! = MediaTweetsLoader(networkService: networkService)
		mediaTweetsLoader.loadMediaTweets(userId: userId) { result in
			mediaTweetsLoader = nil
			completion(result)
		}
    }
}
