//
//  TweetsInteractor.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/6/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

protocol TweetsInteractor: class, UserInteractor {
	var networkService: NetworkService { get }
	
	func retweet(_ tweet: Tweet, completion: @escaping ResultClosure<Bool>)
	func changeLikeStatus(of tweet: Tweet, to like: Bool, completion: @escaping ResultClosure<Bool>)
	func deleteTweet(tweetId: TwitterId, completion: @escaping ResultClosure<Bool>)
}

protocol UserInteractor: class {
	func getRelationsFor(user: User, completion: @escaping ResultClosure<RelationshipWithUser>)
	func followUser(_ user: User, completion: @escaping ResultClosure<Bool>)
	func unFollowUser(_ user: User, completion: @escaping ResultClosure<Bool>)
	func muteUser(_ user: User, completion: @escaping ResultClosure<Bool>)
	func blockUser(_ user: User, completion: @escaping ResultClosure<Bool>)
	func complainUser(_ user: User, completion: @escaping ResultClosure<Bool>)
}

extension TweetsInteractor where Self: BaseInteractor {	
	func loadSealsForTweets(_ tweets: [Tweet], completion: @escaping ResultClosure<[Post]>) {
		let tweetIds: [TweetID] = tweets.map { $0.id }
		let request = Request.Tweets.SealsForTweets(ids: tweetIds)
		networkService.fetchArray(resource: request, completion: completion)
	}
	
	func getUsersVerifiedStatusForTweets(_ tweets: [Tweet], completion: @escaping ResultClosure<UsersVerifiedStatus>) {
		let uniqueUserIds = Array(Set(tweets.map { $0.tweetInfo.user.id }))
		let request = Request.Users.VerifiedStatus(ids: uniqueUserIds)
		networkService.fetch(resource: request, completion: completion)
	}
	
	func getUsersVerifiedStatus(userIDs: [TwitterId], completion: @escaping ResultClosure<UsersVerifiedStatus>) {
		let request = Request.Users.VerifiedStatus(ids: userIDs)
		networkService.fetch(resource: request, completion: completion)
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
	
	func changeLikeStatus(of tweet: Tweet, to like: Bool, completion: @escaping ResultClosure<Bool>) {
		if like {
			likeTweet(tweet, completion: completion)
		} else {
			unliketTweet(tweet, completion: completion)
		}
	}
	
	// MARK: - Private
	
	private func likeTweet(_ tweet: Tweet, completion: @escaping ResultClosure<Bool>) {
		var likeRequest = Request.Tweets.Like()
		likeRequest.tweetId = tweet.id
		networkService.fetch(resource: likeRequest) { (response: Result<Tweet>) in
			switch response {
			case .success(let tweetResponse):
				let isSuccess = tweet.isLiked != tweetResponse.isLiked
				completion(.success(isSuccess))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
	
	private func unliketTweet(_ tweet: Tweet, completion: @escaping ResultClosure<Bool>) {
		var unlikeRequest = Request.Tweets.Unlike()
		unlikeRequest.tweetId = tweet.id
		networkService.fetch(resource: unlikeRequest) { (response: Result<Tweet>) in
			switch response {
			case .success(let tweetResponse):
				let isSuccess = tweet.isLiked != tweetResponse.isLiked
				completion(.success(isSuccess))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}

extension UserInteractor where Self: BaseInteractor {
	
	func getRelationsFor(user: User, completion: @escaping ResultClosure<RelationshipWithUser>) {
		let request = Request.Users.FriendshipsLookup(userId: user.id, screenName: user.screenName)
		networkService.fetchArray(resource: request) { result in
			switch result {
			case .success(let relations):
				guard let relation = relations.first else {
					completion(Result.failure(TwignatureError.unexpectedResult))
					return
				}
				completion(Result.success(relation))
			case .failure(let error):
				completion(Result.failure(error))
			}
		}
	}
	
	private func toBoolClosureAdaptor<ModelType>(boolClosure: @escaping ResultClosure<Bool>) -> ResultClosure<ModelType> {
		return { (result: Result<ModelType>) in
			switch result {
			case .success:
				boolClosure(.success(true))
			case .failure(let error):
				boolClosure(.failure(error))
			}
		}
	}
	
	func followUser(_ user: User, completion: @escaping ResultClosure<Bool>) {
		let resource = Request.Users.UserSingleAction(userId: user.id, type: .follow(enableNotifications: true))
		networkService.fetch(resource: resource, completion: toBoolClosureAdaptor(boolClosure: completion))
	}
	
	func unFollowUser(_ user: User, completion: @escaping ResultClosure<Bool>) {
		let resource = Request.Users.UserSingleAction(userId: user.id, type: .unFollow)
		networkService.fetch(resource: resource, completion: toBoolClosureAdaptor(boolClosure: completion))
	}
	
	func muteUser(_ user: User, completion: @escaping ResultClosure<Bool>) {
		let resource = Request.Users.UserSingleAction(userId: user.id, type: .mute)
		networkService.fetch(resource: resource, completion: toBoolClosureAdaptor(boolClosure: completion))
	}
	
	func blockUser(_ user: User, completion: @escaping ResultClosure<Bool>) {
		let resource = Request.Users.UserSingleAction(userId: user.id, type: .block)
		networkService.fetch(resource: resource, completion: toBoolClosureAdaptor(boolClosure: completion))
	}
	
	func complainUser(_ user: User, completion: @escaping ResultClosure<Bool>) {
		let resource = Request.Users.UserSingleAction(userId: user.id, type: .reportSpam(performBlock: true))
		networkService.fetch(resource: resource, completion: toBoolClosureAdaptor(boolClosure: completion))
	}
	
	func deleteTweet(tweetId: TwitterId, completion: @escaping ResultClosure<Bool>) {
		let resource = Request.Tweets.Destroy(tweetId: tweetId)
		networkService.fetch(resource: resource, completion: toBoolClosureAdaptor(boolClosure: completion))
	}
	
}
