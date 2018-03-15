//
//  Post.swift
//  Twignature
//
//  Created by mac on 02.10.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import ObjectMapper

struct Post {
	let id: String
	let isTwignature: Bool!
	let tweetReferenceId: String?
	let seal: Seal?
}

extension Post: ImmutableMappable {
	
	init(map: Map) throws {
		let intId: Int64 = try map.value("id")
		id = String(intId)
		isTwignature = try map.value("is_twignature")
		seal = try? map.value("seal")
		let optionalIntTweetRefId: Int64? = try? map.value("tweet_ref_id")
		guard let tweetRefId = optionalIntTweetRefId else {
			tweetReferenceId = nil
			return
		}
		tweetReferenceId = String(tweetRefId)
	}
}
