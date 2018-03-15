//
//  UserMentionsInteractor.swift
//  Twignature
//
//  Created by mac on 12.10.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

class UserMentionsInteractor: TweetsForUserInteractor {
	
	override func loadTweets(_ lastTweet: Tweet?, completion: @escaping ResultClosure<[Tweet]>) {
		var lastId: TwitterId?
		
		guard user != nil else {
			return
		}
		let otherCompletion = networkService.filteringArrayTweetsClosure(completion: completion)
		if let lestTweetId = lastTweet?.id, let numId = Int64(lestTweetId), numId > 1 {
			lastId = String(numId - 1)
		}
		if user == Session.current?.user {
			let resource = Request.Tweets.Mentions(count: 20,
			                                       sinceId: nil,
			                                       maxId: lastId)
			networkService.fetchArray(resource: resource, completion: otherCompletion)
		} else {
			let resource = Request.TweetsSearch.searchForMentions(user: user,
			                                                      sinceId: nil,
			                                                      maxId: lastId,
			                                                      count: 100)
			networkService.fetch(resource: resource, completion: { (result) in
				switch result {
				case .success(let result):
					otherCompletion(.success(result.tweets ?? []))
				case .failure(let error):
					completion(.failure(error))
				}
			})
		}
		
	}
}
