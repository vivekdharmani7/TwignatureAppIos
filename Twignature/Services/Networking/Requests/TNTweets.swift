//
//  TNTweets.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/28/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Networking

extension Request {
	
	struct TNTweets: JSONRequest, MapperParsing {
		typealias Model = TempSeal
		
		var host: RequestDestionation = .server
		var path: String
		var parameters: [String : Any]?
		var method: Method = .get
		var parameterEncoding: Networking.ParameterType = .none
		var shouldBeAuthorized: Bool = false
		
		init(ids: [TweetID]) {
			self.path = "posts?ids=" + ids.joined(separator: "&ids=")
		}
	}
	
}
