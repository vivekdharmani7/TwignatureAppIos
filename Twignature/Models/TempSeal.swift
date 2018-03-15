//
//  TempSeal.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/28/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
//is_twignature

import ObjectMapper

struct TempSeal {

	let isTwignature: Bool
	
}

extension TempSeal: ImmutableMappable {
	init(map: Map) throws {
		self.isTwignature = try map.value("is_twignature") ?? false
	}
}
