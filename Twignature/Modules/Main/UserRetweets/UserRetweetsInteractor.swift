//
//  UserRetweetsInteractor.swift
//  Twignature
//
//  Created by mac on 09.10.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

class UserRetweetsInteractor: TweetsForUserInteractor {
	
	override func loadTweets(_ lastTweet: Tweet?, completion: @escaping ResultClosure<[Tweet]>) {
		let resource = Request.Tweets.Retweets(count: 20,
		                                       sinceId: nil,
		                                       maxId: lastTweet?.id.prevId)
        let otherCompletion = networkService.filteringArrayTweetsClosure(completion: completion)
		networkService.fetchArray(resource: resource, completion: otherCompletion)
	}
}
