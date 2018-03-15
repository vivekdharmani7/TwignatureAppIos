//
//  HelpConfiguration.swift
//  Twignature
//
//  Created by mac on 19.10.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import ObjectMapper

struct HelpConfiguration {
	var shortUrlLength: Int
	var shortUrlLengthHttps: Int
}

extension HelpConfiguration: ImmutableMappable {
	
	init(map: Map) throws {
		shortUrlLength = try map.value("short_url_length")
		shortUrlLengthHttps = try map.value("short_url_length_https")
	}
}
