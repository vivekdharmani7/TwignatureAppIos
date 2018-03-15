//
//  Search.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/26/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

extension Request {
	struct TweetsSearch: JSONRequest, MapperParsing {
        
		enum ResultType: String {
			case mixed
			case recent
			case popular
		}
		
		typealias Model = SearchForTweetsResult
		
		let query: String
		let count: Int?
		let geocode: String?
		let lang: String?
		var resultType: ResultType?
		let until: String?
		let sinceId: String?
		let maxId: String?
		let includeEntities: Bool?
		
		var parameters: [String : Any]? {
			var p = [
				"q": query
			]
			
			if let count = count { p["count"] = String(count) }
			if let geocode = geocode { p["geocode"] = geocode }
			if let lang = lang { p["lang"] = lang }
			if let resultType = resultType { p["result_type"] = resultType.rawValue }
			if let until = until { p["until"] = until }
			if let sinceId = sinceId { p["since_id"] = sinceId }
			if let maxId = maxId { p["max_id"] = maxId }
			if let includeEntities = includeEntities { p["include_entities"] = includeEntities ? "true" : "false" }
			p["tweet_mode"] = "extended"
			return p
		}
		
		var path: String { return "search/tweets.json" }
        
        static func searchTotal(query: String, maxId: String?) -> TweetsSearch {
            return TweetsSearch(query: query,
                                count: nil,
                                geocode: nil,
                                lang: nil,
                                resultType: nil,
                                until: nil,
                                sinceId: nil,
                                maxId: maxId,
                                includeEntities: true)
        }
		
		static func searchForReplies(tweet: Tweet, sinceId: String?, maxId: String?, count: Int) -> TweetsSearch {
			let author = tweet.tweetInfo.user.screenName
			let query = "to:\(author)"
			let resource = TweetsSearch(query: query, count: count, geocode: nil, lang: nil,
			                            resultType: .recent,
			                            until: nil,
			                            sinceId: sinceId,
			                            maxId: maxId,
			                            includeEntities: true)
			
			return resource
		}
		
		static func searchForMentions(user: User, sinceId: String?, maxId: String?, count: Int) -> TweetsSearch {
			let mentionedUser = user.screenName
			let query = "@\(mentionedUser)"
			let resource = TweetsSearch(query: query, count: count, geocode: nil, lang: nil,
			                            resultType: .recent,
			                            until: nil,
			                            sinceId: sinceId,
			                            maxId: maxId,
			                            includeEntities: true)
			
			return resource
		}
	}
	
	struct UserTimeLine: JSONRequest, MapperParsing, TweetContained {
		typealias Model = Tweet
		
		let query: String?
		let count: Int?
		let sinceId: String?
		let maxId: String?
		
		var parameters: [String : Any]? {
			var p = [ String: Any ] ()
			p["count"] = count?.description
			p["since_id"] = sinceId
			p["max_id"] = maxId
			p["query"] = query
			p["tweet_mode"] = "extended"
			return p
		}
		
		var path: String { return "statuses/home_timeline.json" }
		
		static func searchForReplies(tweet: Tweet, sinceId: String?, maxId: String?, count: Int) -> UserTimeLine {
			let author = tweet.tweetInfo.user.screenName
			let query = "to:\(author)"
			let resource = UserTimeLine(query: query, count: count,
			                            sinceId: sinceId,
			                            maxId: maxId)
			
			return resource
		}
		
	}
}
