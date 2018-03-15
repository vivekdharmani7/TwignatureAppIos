//
//  UsersVerifiedStatus.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/19/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import ObjectMapper

struct UsersVerifiedStatus {
	let users: [UsersVerifiedStatusItem]
}

struct UsersVerifiedStatusItem {
	let id: Int64
	let verified: Bool
}

extension UsersVerifiedStatusItem: ImmutableMappable {
	init(map: Map) throws {
		id = try map.value("id")
		verified = (try? map.value("verified")) ?? false
	}
}

extension UsersVerifiedStatus: ImmutableMappable {
	init(map: Map) throws {
		users = try map.value("users")
	}
}
