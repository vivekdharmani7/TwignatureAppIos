//
//  UserLikesInteractor.swift
//  Twignature
//
//  Created by Ivan Hahanov on 10/11/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

class UserLikesInteractor: TweetsForUserInteractor {
    override func loadTweets(_ lastTweet: Tweet?, completion: @escaping ResultClosure<[Tweet]>) {
        let resource = Request.Tweets.Favorites(userId: user.id, lastId: lastTweet?.id.prevId)
        let otherCompletion = networkService.filteringArrayTweetsClosure(completion: completion)
        networkService.fetchArray(resource: resource, completion: otherCompletion)
    }
}
