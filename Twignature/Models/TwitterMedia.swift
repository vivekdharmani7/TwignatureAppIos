//
//  TwitterMedia.swift
//  Twignature
//
//  Created by mac on 21.09.17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import ObjectMapper

//it is not complite media structure, there are more fields in response
struct TwitterMedia {

	let mediaIdString: String
	let size: Int
}

extension TwitterMedia: ImmutableMappable {
	
	init(map: Map) throws {
		self.mediaIdString = try map.value("media_id_string")
		self.size = try map.value("size")
	}
}
