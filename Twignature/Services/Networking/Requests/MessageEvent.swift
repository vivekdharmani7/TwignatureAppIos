//
//  MessageEvent.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/5/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import ObjectMapper

struct EmbedEvent {
	
	var event: MessageEvent?
	
	static func create(text: String, recipientId: UserID, mediaId: TwitterId?) -> EmbedEvent {
		let event = MessageEvent.create(text: text, recipientId: recipientId, mediaId: mediaId)
		var embedEvent = Mapper<EmbedEvent>().map(JSONString: "{}")!
		embedEvent.event = event
		return embedEvent
	}
}

extension EmbedEvent: ImmutableMappable, Mappable {
	init(map: Map) {
		event <- map["event"]
	}
	
	mutating func mapping(map: Map) {
		event <- map["event"]
	}
}

struct MessageEvent {
	static func create(text: String, recipientId: UserID, mediaId: TwitterId?) -> MessageEvent {
		var event = Mapper<MessageEvent>().map(JSONString: "{}")!
		event.text = text
		event.recipientId = recipientId
		event.mediaId = mediaId
		return event
	}
	
	fileprivate var type = "message_create"
	fileprivate var recipientId: UserID?
	fileprivate var mediaId: TwitterId?
	fileprivate var text: String?
	
	var messageCreate: [String: Any]?
	var createdTimestamp: Date?
	var id: TwitterId?
}

extension MessageEvent: Mappable {
	init?(map: Map) { }
	
	mutating func mapping(map: Map) {
		id <- map["id"]
		type <- map["type"]
		
		switch map.mappingType {
		case .fromJSON:
			var createTimestampStr: String?
			createTimestampStr <- map["created_timestamp"]
			if let createTimestampStr = createTimestampStr, let createTimestamp = TimeInterval(createTimestampStr) {
				createdTimestamp = Date(timeIntervalSince1970: createTimestamp / 1000)
			}
		case .toJSON:
			var messageData: [String: Any] = ["text" : text ?? ""]
			if let mediaId = mediaId {
				let media = ["id" : mediaId]
				messageData["attachment"] = ["type": "media", "media" : media]
			}
			messageCreate = ["target" : ["recipient_id" : recipientId],
			                  "message_data": messageData]
			
		}
		
		messageCreate <- map["message_create"]
	}
}
