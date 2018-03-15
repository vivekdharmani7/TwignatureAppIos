//
//  TweetsForUserInteractor.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/6/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

class TweetsForUserInteractor: BaseInteractor, TweetsInteractor {
    weak var presenter: TweetsForUserPresenter!
	var user: User!

	func loadTweets(_ lastTweet: Tweet?, completion: @escaping ResultClosure<[Tweet]>) {
		let lastId = lastTweet?.id.prevId
		let resource = Request.Tweets.Timeline(userId: user.id, lastId: lastId)
        let otherCompletion = networkService.filteringArrayTweetsClosure(completion: completion)
		networkService.fetchArray(resource: resource, completion: otherCompletion)
	}
}
