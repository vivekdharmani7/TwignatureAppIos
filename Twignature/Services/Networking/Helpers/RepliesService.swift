//
//  RepliesService.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/20/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

private let queryCountLimit = 5
private let desiredMinimumCount = 5
private let tweetsPerRequest = 100

enum RepliesMode {
	case byCurrentUser
	case byOthers
}

typealias RepliesCompletion = ResultClosure<[Tweet]>

class RepliesService {
	private(set) lazy var networkService: NetworkService = NetworkService()
	private(set) var noMoreReplies = false {
		didSet {
			if noMoreReplies { debugPrint("No more replies") }
		}
	}
	private(set) var tweet: Tweet!
	private(set) var mode: RepliesMode
	
	init(tweet: Tweet, mode: RepliesMode) {
		self.tweet = tweet
		self.mode = mode
	}
	
	func reset() {
		currentMaxId = nil
		noMoreReplies = false
		prepareForNextRequest()
	}
	
	private func prepareForNextRequest() {
		queryCounter = 0
		replies = []
	}
	
	func fetchMoreReplies(completion: @escaping RepliesCompletion) {
		prepareForNextRequest()
		fetchCommentsPage(sinceId: tweet.id, maxId: currentMaxId, completion: completion)
	}
	
	private var queryCounter = 0
	private var replies = [Tweet]()
	private var currentMaxId: TwitterId?
	
	private func fetchCommentsPage(sinceId: TwitterId?,
	                               maxId: TwitterId?,
	                               completion: @escaping RepliesCompletion) {
		
		guard !noMoreReplies else {
			debugPrint("there is no more tweets")
			self.repliesDidFetched(completion: completion)
			return
		}
		
		var maXidString : String?
		if let maxId = maxId {
			maXidString = String(maxId)
		}
		let otherCompletion = networkService.filteringArrayTweetsClosure(completion: completion)
		switch mode {
		case .byCurrentUser:
			let resource = Request.UserTimeLine.searchForReplies(tweet: tweet,
			                                                     sinceId: sinceId,
			                                                     maxId: maXidString,
			                                                     count: tweetsPerRequest)
			networkService.fetchArray(resource: resource) { [weak self] result in
				self?.processArrayResult(searchResult: result, completion: otherCompletion)
			}
		case .byOthers:
			let resource = Request.TweetsSearch.searchForReplies(tweet: tweet,
			                                                     sinceId: sinceId,
			                                                     maxId: maXidString,
			                                                     count: tweetsPerRequest)
			networkService.fetch(resource: resource) { [weak self] searchResult in
				self?.processResult(searchResult: searchResult, completion: otherCompletion)
			}
		}
	}
	
	private func processArrayResult(searchResult: Result<[Tweet]>,
	                                completion: @escaping  RepliesCompletion) {
		switch searchResult {
		case .success(let tweets):
			processReplies(tweets: tweets, completion: completion)
		case .failure(let error):
			let result: Result<[Tweet]> = Result.failure(error)
			completion(result)
		}
	}
	
	private func processResult(searchResult: Result<SearchForTweetsResult>,
						   completion: @escaping RepliesCompletion) {
		switch searchResult {
		case .success(let results):
			processReplies(tweets: results.tweets, completion: completion)
		case .failure(let error):
			let result: Result<[Tweet]> = Result.failure(error)
			completion(result)
		}
	}
	
	private func processReplies(tweets: [Tweet]?, completion: @escaping RepliesCompletion) {
		
		guard let tweets = tweets, !tweets.isEmpty else {
			debugPrint("no more tweets")
			noMoreReplies = true
			repliesDidFetched(completion: completion)
			return
		}
		
		let res = tweets.filter {
			return $0.tweetInfo.inReplyToStatusId == self.tweet.id
		}
		
		print("============================  \(res.count) of \(tweets.count)")
		if mode == RepliesMode.byCurrentUser {
			print(tweets.count)
		}
		replies += res
		queryCounter += 1
		currentMaxId = tweets.last?.id.prevId
		
		guard tweets.count >= tweetsPerRequest, queryCounter <= queryCountLimit else {
			noMoreReplies = true
			repliesDidFetched(completion: completion)
			return
		}
		
		guard let maxId = currentMaxId,
			replies.count <= desiredMinimumCount else {
				repliesDidFetched(completion: completion)
				return
		}
		
		fetchCommentsPage(sinceId: tweet.id, maxId: maxId, completion: completion)
	}
	
	private func repliesDidFetched(completion: RepliesCompletion) {
		debugPrint("replies queryCounter=\(queryCounter) found=\(replies.count)")
		let result: Result<[Tweet]> = Result.success(replies)
		completion(result)
		getSeals(replies: replies)
	}
	
	private func getSeals(replies: [Tweet]) {
		guard !replies.isEmpty  else { return }
		let ids = replies.map { $0.id }
		let resource = Request.TNTweets(ids: ids)
		networkService.fetchArray(resource: resource) { result in // [weak self] result in
			switch result {
			case .success(let seals):
				print("seals.count = \(seals.count)")
				print(seals)
			case .failure(let error):
				print(error.localizedDescription)
			}
		}
	}
}
