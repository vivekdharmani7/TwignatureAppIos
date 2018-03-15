//
//  Conversation.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/28/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

struct Conversation {
	var messages: [Message]
	var user: User
	var lastActivityDate : Date {
		return messages.first?.createdAt ?? Date.distantPast
	}
		
	static func groupByUsers(userID: UserID, messages: [Message]) -> [Conversation] {
		
		var convDict = [UserID : Conversation]()
		for message in messages {
			let partner = message.sender.id == userID ? message.recipient : message.sender
			var conversation = convDict[partner.id] ?? Conversation(messages: [], user: partner)
			conversation.messages.append(message)
			convDict[partner.id] = conversation
		}
		
		let conversations: [Conversation] = convDict.map {
			var modified: Conversation = $0.value
			modified.messages.sort(by: { $0.0.createdAt > $0.1.createdAt })
			return modified
		}
		
		return conversations.sorted(by: { $0.0.lastActivityDate > $0.1.lastActivityDate })
	}
}
