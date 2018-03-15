//
//  FeedInteractor.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/4/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

class FeedInteractor: BaseInteractor, TweetsInteractor {
	weak var presenter: FeedPresenter!
    private var page: Int?
    private var query: String?
    private var filter: FeedViewModel.SearchFilter?
    var maxTweetId: String?
    
    // MARK: - Actions
	func updateTwitterConfiguration() {
		let request = Request.Help()
		networkService.fetch(resource: request) { (result) in
			switch result {
			case .success(let configuration):
				AppDefined.maxTweetLettersNumber = AppDefined.maxBasicLettersNumber - configuration.shortUrlLengthHttps - 1
			case .failure: break
			}
		}
	}
	
	func updateUserImage() {
//		Twitter.sharedInstance().APIClient.loadUserWithID( session.userID )
//		{
//			(user, error) -> Void in
//			if( user != nil )
//			{
//				println( user.profileImageURL )
//			}
//		}
	}
    
    func reloadData() {
        if let query = query, let filter = filter {
            performSearch(query: query, filter: filter)
        } else {
            loadTweets()
        }
    }
	
	func loadSealsForTweets(_ tweets: [Tweet], completion: @escaping ResultClosure<[Post]>) {
		let tweetIds = tweets.map { (tweet) -> TweetID in
			return tweet.id
		}
		let request = Request.Tweets.SealsForTweets(ids: tweetIds)
		networkService.fetchArray(resource: request, completion: completion)
	}
	
    func loadTweets(maxId: TwitterId?, completion: @escaping ResultClosure<[Tweet]>) {
        self.maxTweetId = maxId
		let tweetsRequst: Request.Tweets.Feed = Request.Tweets.Feed(maxId)
        let otherCompletion = networkService.filteringArrayTweetsClosure(completion: completion)
        networkService.fetchArray(resource: tweetsRequst) { result in
            switch result {
            case .success(let tweets):
                self.maxTweetId = tweets.sorted { $0.numberInt > $1.numberInt }.last?.id
                otherCompletion(.success(tweets))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loadTweets() {
        self.loadTweets(maxId: nil, completion: { [weak self] result in
            switch result {
            case .success(let tweets):
                self?.presenter.didReload(tweets: tweets)
            case .failure(let error):
                self?.presenter.didFail(error: error)
            }
        })
    }
    
    func loadMoreTweets() {
        guard let maxId = self.maxTweetId?.prevId else { return }
        loadTweets(maxId: maxId) { [weak self] result in
            switch result {
            case .success(let tweets):
                self?.presenter.didLoadMore(tweets: tweets)
            case .failure(let error):
                self?.presenter.didFail(error: error)
            }
        }
    }
    
    func retweet(_ tweet: Tweet, completion: @escaping ResultClosure<Bool>) {
        let tweetId = tweet.id
        let request = Request.Tweets.Retweet(tweetId: tweetId)
        networkService.fetch(resource: request) { result in
            switch result {
            case .success:
                completion(.success(true))
                break
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }
    }
    
    func resetSearch() {
        query = nil
        maxTweetId = nil
        filter = nil
        workItem?.cancel()
    }
    
    func performSearch(query: String? = nil, filter: FeedViewModel.SearchFilter? = nil) {
        
        debounce(sec: 0.5) { [unowned self] in
            guard self.query != query || self.filter != filter else { return }
            self.query = query ?? self.query
            self.filter = filter ?? self.filter
            guard let unwrappedFilter = self.filter, let unwrappedQuery = self.query else { return }
            switch unwrappedFilter {
            case .people:
                self.loadPeople(query: unwrappedQuery, page: 0, completion: { [weak self] result in
                    switch result {
                    case .success(let users):
                        self?.presenter.didReload(users: users)
                    case .failure(let error):
                        self?.presenter.didFail(error: error)
                    }
                })
            case .tweets:
                self.loadTweets(query: unwrappedQuery, maxId: nil, completion: { [weak self] result in
                    switch result {
                    case .success(let tweets):
                        self?.presenter.didReload(tweets: tweets)
                    case .failure(let error):
                        self?.presenter.didFail(error: error)
                    }
                })
            }
        }
    }
    
    func loadMoreData() {
        guard let query = query, let filter = filter else { return }
        switch filter {
        case .people:
            self.loadMorePeople(query: query) { [weak self] result in
                switch result {
                case .success(let users):
                    self?.presenter.didLoadMore(users: users)
                case .failure(let error):
                    self?.presenter.didFail(error: error)
                }
            }
        case .tweets:
            self.loadMoreTweets(query: query) { [weak self] result in
                switch result {
                case .success(let tweets):
                    self?.presenter.didLoadMore(tweets: tweets)
                case .failure(let error):
                    self?.presenter.didFail(error: error)
                }
            }
        }
    }
    
    private func loadPeople(query: String, page: Int, completion: @escaping ResultClosure<[User]>) {
        self.page = page
        let request = Request.Users.Search(query: query, page: page)
        networkService.fetchArray(resource: request, completion: completion)
    }
    
    private func loadMorePeople(query: String, completion: @escaping ResultClosure<[User]>) {
        guard let page = self.page else { return }
        loadPeople(query: query, page: page + 1, completion: completion)
    }
    
    private func loadTweets(query: String, maxId: String?, completion: @escaping ResultClosure<[Tweet]>) {
        self.maxTweetId = maxId
        let request = Request.TweetsSearch.searchTotal(query: query, maxId: maxId)
        let otherCompletion = networkService.filteringArrayTweetsClosure(completion: completion)
        networkService.fetch(resource: request) { result in
            switch result {
            case .success(let response):
                self.maxTweetId = response.tweets?.sorted { $0.numberInt > $1.numberInt }.last?.id ?? self.maxTweetId
                otherCompletion(.success(response.tweets ?? []))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func loadMoreTweets(query: String, completion: @escaping ResultClosure<[Tweet]>) {
        guard let maxId = self.maxTweetId?.prevId else { return }
        let otherCompletion = networkService.filteringArrayTweetsClosure(completion: completion)
        loadTweets(query: query, maxId: maxId, completion: otherCompletion)
    }
}
