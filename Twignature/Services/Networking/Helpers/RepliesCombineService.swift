//
//  RepliesCombineService.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/26/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

final class RepliesCombineService {
	private var userRepliesService: RepliesService!
	private var othersRepliesService: RepliesService!
	private(set) var tweet: Tweet!
	
	init(tweet: Tweet) {
		self.tweet = tweet
		userRepliesService = RepliesService(tweet: tweet, mode: .byCurrentUser)
		othersRepliesService = RepliesService(tweet: tweet, mode: .byOthers)
	}
	
	func reset() {
		userRepliesService.reset()
		othersRepliesService.reset()
	}
	
	var noMoreReplies: Bool {
		return userRepliesService.noMoreReplies && othersRepliesService.noMoreReplies
	}
	
	func fetchMoreReplies(completion: @escaping ResultClosure<[Tweet]>) {
        let otherCompletion = userRepliesService.networkService.filteringArrayTweetsClosure(completion: completion)
		guard !noMoreReplies else {
			let emptyResult = Result<[Tweet]>.success([])
			completion(emptyResult)
			return
		}
		
		let group = DispatchGroup() // TODO: consider rewriting this with OperationQueue() in order to cancel on error
		var results = [Result<[Tweet]>] ()
		
		group.enter()
		group.enter()
		userRepliesService.fetchMoreReplies { result in
			results.append(result)
			group.leave()
		}
		
		othersRepliesService.fetchMoreReplies { result in
			results.append(result)
			group.leave()
		}
		
		var tweets = Set<Tweet>()
		group.notify(queue: DispatchQueue.global(qos: .background)) {
			for result in results {
				switch result {
				case .success(let newReplies):
					for reply in newReplies {
						tweets.insert(reply)
					}
				case .failure:
					DispatchQueue.main.async {
						completion(result)
					}
					return
				}
			}
			
			let sortedTweets = tweets.sorted { $0.0.createdAt > $0.1.createdAt }
			
			let combinedResult = Result<[Tweet]>.success(sortedTweets)
			DispatchQueue.main.async {
				otherCompletion(combinedResult)
			}
		}		
	}
}
