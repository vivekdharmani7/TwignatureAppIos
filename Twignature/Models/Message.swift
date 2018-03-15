//
//  Message.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/28/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import ObjectMapper

struct Message: HasStringID {
	let id: TwitterId
	let createdAt: Date
	let sender: User
	let recipient: User
	let text: String
	var textWithoutMediaLinks: String
	let media: [MediaItem]?
}

extension Message: ImmutableMappable {
	
	init(map: Map) throws {
		self.id = try map.value("id_str")
		self.sender = try map.value("sender")
		self.recipient = try map.value("recipient")
		self.text = try map.value("text")
		self.media = try? map.value("entities.media")
		let dateTransform = TimezoneDateFormatterTransform(dateFormatter: TwitterDateFormatter(),
		                                                   serverTimeZone: .utc,
		                                                   destinationTimeZone: .current)
		self.createdAt = try map.value("created_at", using: dateTransform)
		self.textWithoutMediaLinks = Message.getTextWithoutMediaLinks(text: text, media: media)
	}
	
	private static func getTextWithoutMediaLinks(text: String, media: [MediaItem]?) -> String {
		guard let media = media else { return text }
		var retTxt = text
		for mediaItem in media {
			let repl1 = mediaItem.url.absoluteString + " "
			let repl2 = " " + mediaItem.url.absoluteString
			retTxt = retTxt.replacingOccurrences(of: repl1, with: "")
			retTxt = retTxt.replacingOccurrences(of: repl2, with: "")
		}
		
		return retTxt
	}
}
