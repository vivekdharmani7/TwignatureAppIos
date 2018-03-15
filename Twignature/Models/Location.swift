//
//  Location.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/15/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import ObjectMapper

struct Location {
    let latitude: Double
    let longitude: Double
}

extension Location: ImmutableMappable {
    init(map: Map) throws {
        latitude = try map.value("")
        longitude = try map.value("")
    }
	
	init(_ latitude: Double, _ longitude: Double) {
		self.latitude = latitude
		self.longitude = longitude
	}
}
