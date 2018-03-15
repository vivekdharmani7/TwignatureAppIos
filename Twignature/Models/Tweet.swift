//
//  Tweet.swift
//  Twignature
//
//  Created by Ivan Hahanov on 8/31/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import ObjectMapper

protocol PossiblySensitive {
    var possiblySensitive: Bool? { get set }
}

struct Tweet: HasStringID {

	//tweet info
	var numberInt: Int64 { return id.numId ?? 0 }
    let id: String

    let place: Place?

//    let retweetText: String?
//	let retweetAuthorName: String?
    let createdAt: Date
    var likesCount: Int
    var retweetCount: Int
    var isLiked: Bool
    var isRetweeted: Bool

	let latitude: Double?
	let longitude: Double?
	var seal: Seal?
	var tweetReferenceId: String?
	let isTwignature: Bool?
	let originTweetId: String?
    let retweetedPossiblySensitive: Bool?

	var tweetInfo: TweetInfo
	var retweetInfo: TweetInfo?
}

struct TweetInfo: ImmutableMappable, PossiblySensitive {
	var user: User
	fileprivate(set) var text: String
	let hashtags: [String]
	let mentionedUsers: [MentionedUser]
	let media: [MediaItem]?
	let extendedMedia: [MediaItem]?
	let extendedUrl: String?
	let url: String?
	let inReplyToStatusId: String?
	let inReplyToScreenName: String?
	var possiblySensitive: Bool?

	init(map: Map) throws {
		let hashtagsResponse = try map.value("entities.hashtags") as [[String : Any]]
		self.user = try map.value("user")
		self.hashtags = hashtagsResponse.flatMap({ $0["text"] as? String }).map({ "#\($0)" })
		self.mentionedUsers = try map.value("entities.user_mentions")
		self.media = try? map.value("entities.media")
        self.extendedMedia = try? map.value("extended_entities.media")
		self.url = try? map.value("entities.urls.url")
		self.extendedUrl = try? map.value("entities.urls.expanded_url")
		// ExtendedMedia
		let mediaUrlStrings = extendedMedia?.flatMap({ $0.url.absoluteString })
		self.possiblySensitive = try? map.value("possibly_sensitive")
		// origin tweet
		let regularText: String? = try? map.value("text")
		let fullText: String? = try? map.value("full_text")
		var textResponse: String = fullText ?? regularText ?? ""
		mediaUrlStrings?.forEach {
			if textResponse.contains($0) {
				textResponse = textResponse.replacingOccurrences(of: $0, with: "")
			}
		}
		self.text = textResponse
		let retweetUsername: String? = try? map.value("retweeted_status.user.screen_name")
		let retweetMark = "RT @\(retweetUsername ?? ""):"
		if textResponse.contains(retweetMark) {
			self.text = ""
		}
		self.inReplyToStatusId = try? map.value("in_reply_to_status_id_str")
		self.inReplyToScreenName = try? map.value("in_reply_to_screen_name")
	}
}

extension Tweet: ImmutableMappable {
    
    init(map: Map) throws {
        self.id = try map.value("id_str")
        self.place = try? map.value("place")
	    self.originTweetId = try? map.value("retweeted_status.id_str")
        self.likesCount = self.originTweetId == nil ? try map.value("favorite_count") : try map.value("retweeted_status.favorite_count")
        self.retweetCount = try map.value("retweet_count")
        self.isLiked = try map.value("favorited")
        self.isRetweeted = try map.value("retweeted")

		self.tweetInfo = try TweetInfo(map: map)
		self.retweetInfo = try? map.value("retweeted_status")

		self.latitude = try? map.value("coordinates.coordinates.1")
		self.longitude = try? map.value("coordinates.coordinates.0")
		self.seal = try? map.value("seal")
		self.isTwignature = try? map.value("is_twignature")
		self.tweetReferenceId = try? map.value("tweet_ref_id")

        self.retweetedPossiblySensitive = try? map.value("retweeted_status.possibly_sensitive")

        // Createdate
        let dateTransform = TimezoneDateFormatterTransform(dateFormatter: TwitterDateFormatter(),
                                                           serverTimeZone: .utc,
                                                           destinationTimeZone: .current)
        createdAt = try map.value("created_at", using: dateTransform)
    }
}

extension TweetInfo {

	func extractTextAndReplyTo() -> (replyToNames: String, text: String) {
		guard inReplyToStatusId != nil else {
			return (replyToNames: "", text: text)
		}
		let tokens = text.components(separatedBy: " ")
		var names = [String]()
		for token in tokens {
			guard token.first == "@",
				  let name = token.split(separator: "\n").first
					else {
				break
			}
			names.append(String(name))
		}

		guard !names.isEmpty else {
			if let inReplyToScreenName = self.inReplyToScreenName {
				return (replyToNames: "@\(inReplyToScreenName)", text: text)
			}
			return (replyToNames: "", text: text)
		}

		let stringToCut = names.joined(separator: " ")
		let replyToNames = names.joined(separator: ", ")
		guard text.endIndex > stringToCut.endIndex else {
			return (replyToNames: replyToNames, text: text)
		}
		let index = text.index(after: stringToCut.endIndex)
		let resultText = text.substring(from: index)

		return (replyToNames: replyToNames, text: resultText)
	}
}


extension Tweet {
	
	var shareURL: String {
		return self.tweetInfo.url ?? "https://twitter.com/\(self.tweetInfo.user.screenName)/statuses/\(id)"
	}

	var shouldBeCovered: Bool {
		let shouldDisplaySensetiveContent = Session.current?.user.shouldDisplaySensetiveContent ?? false
		let isTweetPossiblySensitive = (self.tweetInfo.possiblySensitive ?? false) || (self.retweetInfo?.possiblySensitive ?? false)
		return isTweetPossiblySensitive && !shouldDisplaySensetiveContent
	}
}
