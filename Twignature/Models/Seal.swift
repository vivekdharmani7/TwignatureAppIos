//
//  Seal.swift
//  Twignature
//
//  Created by mac on 28.09.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import ObjectMapper

struct Seal {
	let infoUrl: String
	let sealDescription: String
	let imagePath: String
}

extension Seal: ImmutableMappable {
	
	init(map: Map) throws {
		self.infoUrl = try map.value("info_url")
		self.sealDescription = try map.value("description")
		self.imagePath = try map.value("image.url")
	}
}
