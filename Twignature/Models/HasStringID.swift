//
//  HasStringID.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/28/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

typealias TwitterId = String

extension TwitterId {
	var numId: Int64? {
		return Int64(self)
	}
	
	var nextId: TwitterId? {
		var retVal: TwitterId?
		if let numId = numId {
			retVal = TwitterId(numId + 1)
		}
		return retVal
	}
	
	var prevId: TwitterId? {
		var retVal: TwitterId?
		if let numId = numId {
			retVal = TwitterId(numId - 1)
		}
		return retVal
	}
}

protocol HasStringID: Hashable {
	var id: String { get }
}

extension HasStringID {
	var hashValue: Int { return id.hashValue }
	
	static func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.id == rhs.id
	}
}
