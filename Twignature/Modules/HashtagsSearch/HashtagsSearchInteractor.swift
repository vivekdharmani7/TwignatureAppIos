//
//  HastagsSearchInteractor.swift
//  Twignature
//
//  Created by mac on 14.11.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

class HashtagsSearchInteractor: TweetsForUserInteractor {
    var hashtag: String = ""

    override func loadTweets(_ lastTweet: Tweet?, completion: @escaping ResultClosure<[Tweet]>) {
        workItem?.cancel()
        let request = Request.TweetsSearch.searchTotal(query: "#\(hashtag)", maxId: lastTweet?.id)
        networkService.fetch(resource: request) { (result: Result<SearchForTweetsResult>) in
            switch result {
                case .success(let searchModel):
                    completion(.success(searchModel.tweets ?? []))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
}
