//
//  TNChatItem.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/1/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Chatto
import ChattoAdditions

class TNChatItem: ChatItemProtocol, TextMessageModelProtocol {
	static let typeName = "TNChatItem"
	var text: String
	
	var messageModel: MessageModelProtocol
	
	var type: ChatItemType
	var uid: String

	init(message: Message) {
		uid = message.id
		type = TNChatItem.typeName
		let isIncoming = message.recipient.id == Session.current?.user.id
		messageModel = MessageModel(uid: message.recipient.id,
		                            senderId: message.sender.id,
		                            type: type,
		                            isIncoming: isIncoming,
		                            date: message.createdAt,
		                            status: .success)
		text = message.textWithoutMediaLinks
	}
}
