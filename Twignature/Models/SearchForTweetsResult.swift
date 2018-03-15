//
//  SearchForTweetsResult.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/20/17.
//  Copyright © 2017 Applikey. All rights reserved.
//
import ObjectMapper

protocol SearchForTweetsResultProtocol {
    var tweets: [Tweet]? { get set }
}

struct SearchForTweetsResult: SearchForTweetsResultProtocol {
	var tweets: [Tweet]?
	let metadata: [String: Any]?
}

extension SearchForTweetsResult: ImmutableMappable {
	init(map: Map) {
		tweets = try? map.value("statuses")
		metadata = try? map.value("search_metadata")
	}
}
