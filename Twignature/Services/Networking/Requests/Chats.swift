//
//  Chats.swift
//  Twignature
//
//  Created by Anton Muratov on 9/20/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Networking

extension Request {
    enum Chats {
		struct MessagesReceived: JSONRequest, MapperParsing {
			typealias Model = Message
			
			let count: Int?
			let sinceId: String?
			let maxId: String?
			
			let path: String = "direct_messages.json"
			var parameters: [String : Any]? {
				var p = [String : Any]()
				if let count = count { p["count"] = String(count) }
				if let sinceId = sinceId { p["since_id"] = sinceId }
				if let maxId = maxId { p["max_id"] = maxId }
				return p
			}
		}
		
		struct MessagesSent: JSONRequest, MapperParsing {
			typealias Model = Message
			
			let count: Int?
			let sinceId: String?
			let maxId: String?
			
			let path: String = "direct_messages/sent.json"
			var parameters: [String : Any]? {
				var p = [String : Any]()
				if let count = count { p["count"] = String(count) }
				if let sinceId = sinceId { p["since_id"] = sinceId }
				if let maxId = maxId { p["max_id"] = maxId }
				return p
			}
		}
		
		struct SendNew: JSONRequest, MapperParsing {
			typealias Model = Message
			
			let path: String = "direct_messages/new.json"
			let method: Method = .post		
			
			let parameterEncoding: Networking.ParameterType = .json
			private(set) var parameters: [String : Any]?

			init(userId: TwitterId, screenName: String, text: String, media: TwitterMedia?) {
				var p = [String : Any]()
				p["user_id"] = userId
				p["screen_name"] = screenName
				p["text"] = text
				parameters = p
			}

		}
		
		struct SendMessage: JSONRequest, MapperParsing {
			typealias Model = EmbedEvent
			
			let path: String = "direct_messages/events/new.json"
			let method: Method = .post
			
			let parameterEncoding: Networking.ParameterType = .json
			private(set) var parameters: [String : Any]?
			private(set) var jsonBody: String?
			var httpBody: Data? {
				return jsonBody?.data(using: String.Encoding.utf8)
			}
			
			init(userId: TwitterId, screenName: String, text: String, media: TwitterMedia?) {
				let mediaId = media?.mediaIdString
				let embedEvent = EmbedEvent.create(text: text, recipientId: userId, mediaId: mediaId)
				jsonBody = embedEvent.toJSONString()
			}
			
		}
		
	}
}
