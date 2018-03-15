//
//  TwignatureFeedInteractor.swift
//  Twignature
//
//  Created by Ivan Hahanov on 10/18/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

class TwignatureFeedInteractor: TweetsForUserInteractor {
	override func loadTweets(_ lastTweet: Tweet?, completion: @escaping ResultClosure<[Tweet]>) {
		networkService.cancelRequest()
		let request = Request.TweetsSearch.searchTotal(query: "#signrs AND -filter:retweets AND -filter:replies", maxId: lastTweet?.id.prevId)
		let otherCompletion = networkService.filteringArrayTweetsClosure(completion: completion)
		networkService.fetch(resource: request) { result in
			switch result {
			case .success(let response):
                otherCompletion(.success(response.tweets ?? []))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}
