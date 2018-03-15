//
//  Identifier.swift
//  Twignature
//
//  Created by mac on 18.10.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

import ObjectMapper

struct Identifier {
	let id: String
}

extension Identifier: ImmutableMappable {
	
	init(map: Map) throws {
		let intId: Int64 = try map.value("id")
		id = String(intId)
	}
}
