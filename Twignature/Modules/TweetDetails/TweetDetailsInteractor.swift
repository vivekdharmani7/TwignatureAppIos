//
//  TweetDetailsInteractor.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/18/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

class TweetDetailsInteractor: BaseInteractor, TweetsInteractor {
	
	private(set) var tweet: Tweet?
	
	var configuration: TweetDetailsConfiguration? {
		didSet {
			guard let tweet = configuration?.tweet else { return }
			self.tweet = tweet
			repliesService = RepliesCombineService(tweet: tweet)
		}
	}
	
    weak var presenter: TweetDetailsPresenter!
	
    func loadSealsForTweets(_ tweets: [Tweet], completion: @escaping ResultClosure<[Post]>) {
        let tweetIds = tweets.map { (tweet) -> TweetID in
            return tweet.id
        }
        let request = Request.Tweets.SealsForTweets(ids: tweetIds)
        networkService.fetchArray(resource: request, completion: completion)
    }
        
	func fetchRepliesFromScretch(completion: @escaping ResultClosure<[Tweet]>) {
		repliesService.reset()
		fetchMoreReplies(completion: completion)
	}
	
	func fetchMoreReplies(completion: @escaping ResultClosure<[Tweet]>) {
        let otherCompletion = networkService.filteringArrayTweetsClosure(completion: completion)
		repliesService.fetchMoreReplies(completion : otherCompletion)
	}
	
	// MARK: - Private
	private var repliesService: RepliesCombineService!
	var hasMoreReplies: Bool {
		return !repliesService.noMoreReplies
	}
}
