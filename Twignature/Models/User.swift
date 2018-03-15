//
//  User.swift
//  Twignature
//
//  Created by Ivan Hahanov on 8/29/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import ObjectMapper
import TwitterKit

//MARK: User
typealias UserID = TwitterId

struct EmbedUsers {
	fileprivate(set) var users: [User]?
	fileprivate(set) var nextCursor: Int?
}

extension EmbedUsers: ImmutableMappable {
	init(map: Map) throws {
		users = try? map.value("users")
		nextCursor = try? map.value("next_cursor")
	}
}

struct RelationshipWithUser {
	var name: String?
	var screenName: String?
	var id: TwitterId
	var connections: [String]?
	var isFollowedBy: Bool = false
	var isFollowing: Bool = false
}

extension RelationshipWithUser: ImmutableMappable {
	init(map: Map) throws {
		name = try? map.value("name")
		screenName = try? map.value("screen_name")
		id = (try? map.value("id")) ?? ""
		connections = try? map.value("connections")
		isFollowedBy = connections?.first(where: { $0 == "followed_by" }) != nil
		isFollowing = connections?.first(where: { $0 == "following" }) != nil
	}
}

struct User: HasStringID {
    fileprivate(set) var id: UserID
    fileprivate(set) var name: String
    fileprivate(set) var screenName: String
	var isVerified: Bool
	fileprivate(set) var profileLocation: String?
	fileprivate(set) var profileUrl: URL?
    fileprivate(set) var profileImageUrl: URL?
    fileprivate(set) var profileImageUrlOriginal: URL?
	fileprivate(set) var expandedUrl: URL?
    fileprivate(set) var profileBackgroundImageUrl: URL?
	fileprivate(set) var profileBannerUrl: URL?
    fileprivate(set) var followersCount: Int
    fileprivate(set) var friendsCount: Int
    fileprivate(set) var description: String?
    fileprivate(set) var details: Details?
	fileprivate(set) var seal: Seal?
    fileprivate(set) var following: Bool?
    var shouldDisplaySensetiveContent: Bool?
	
	mutating func mergeTemporaryUser(_ user: TempUser) {
		id = user.id ?? id
		name = user.name ?? name
		screenName = user.screenName ?? screenName
		isVerified = user.isVerified ?? isVerified
		profileImageUrl = user.profileImageUrl ?? profileImageUrl
		profileBannerUrl = user.profileBannerUrl ?? profileBannerUrl
		profileBackgroundImageUrl = user.profileBackgroundImageUrl ?? profileBackgroundImageUrl
		followersCount = user.followersCount ?? followersCount
		friendsCount = user.friendsCount ?? friendsCount
		description = user.description ?? description
		details = user.details ?? details
		seal = user.seal ?? seal
		profileUrl = user.profileUrl ?? profileUrl
		expandedUrl = user.expandedUrl ?? expandedUrl
	}
	
	mutating func mergeUser(_ user: User) {
		id = user.id
		name = user.name
		screenName = user.screenName
		isVerified = user.isVerified ? user.isVerified : isVerified
		profileImageUrl = user.profileImageUrl ?? profileImageUrl
		profileBackgroundImageUrl = user.profileBackgroundImageUrl ?? profileBackgroundImageUrl
        profileImageUrlOriginal = user.profileImageUrlOriginal ?? profileImageUrlOriginal
		followersCount = user.followersCount
		friendsCount = user.friendsCount
		description = user.description ?? description
		details = user.details ?? details
		seal = user.seal ?? seal
		profileUrl = user.profileUrl ?? profileUrl
		profileLocation = user.profileLocation ?? profileLocation
        following = user.following ?? following
	}
}

extension User: ImmutableMappable {
    
    init(map: Map) throws {
        id = try map.value("id_str")
        name = try map.value("name")
        screenName = try map.value("screen_name")
        isVerified = try map.value("verified")
        profileImageUrl = try? map.value("profile_image_url", using: URLTransform())
        let originalProfileUrlString: String? = try? map.value("profile_image_url")
        profileImageUrlOriginal = URL(string: originalProfileUrlString?.replacingOccurrences(of: "_normal", with: "") ?? "")
		profileBannerUrl = try? map.value("profile_banner_url", using: URLTransform())
        profileBackgroundImageUrl = try? map.value("profile_background_image_url", using: URLTransform())
        followersCount = try map.value("followers_count")
        friendsCount = try map.value("friends_count")
        description = try? map.value("description")
        details = try Details(map: map)
		seal = try? map.value("seal")
		profileLocation = try? map.value("location")
		profileUrl = try? map.value("entities.url.urls.0.display_url", using: URLTransform())
		expandedUrl = try? map.value("entities.url.urls.0.expanded_url", using: URLTransform())
        following = try? map.value("following")
    }
}

extension User {
    struct Details {
        let followersCount: Int
        let followingCount: Int
        let likesCount: Int
        let tweetsCount: Int
        let location: String?
    }
}

extension User.Details: ImmutableMappable {
    init(map: Map) throws {
        followersCount = try map.value("followers_count")
        followingCount = try map.value("friends_count")
        likesCount = try map.value("favourites_count")
        tweetsCount = try map.value("statuses_count")
        location = try? map.value("location")
    }
}

//MARK: TWTRUser
extension User {
	init(twitterUser: TWTRUser) {
		self.id = twitterUser.userID
		self.name = twitterUser.name
		self.isVerified = twitterUser.isVerified
		self.profileImageUrl = URL(string: twitterUser.profileImageURL)!
        self.profileImageUrlOriginal = URL(string: twitterUser.profileImageLargeURL)
		self.profileBannerUrl = nil
		self.profileBackgroundImageUrl = nil
		self.description = twitterUser.description
		self.screenName = twitterUser.screenName
		self.followersCount = 0
		self.friendsCount = 0
		self.details = nil
	}
}

//MARK: TempUser
/*
This entity is used to get partial user model
and perform merging of it to user entity
*/
struct TempUser {
	let id: String?
	let name: String?
	let screenName: String?
	let isVerified: Bool?
	let profileImageUrl: URL?
	let profileBannerUrl: URL?
	let profileBackgroundImageUrl: URL?
	let followersCount: Int?
	let friendsCount: Int?
	let description: String?
	let details: User.Details?
	let seal: Seal?
	let expandedUrl: URL?
	let profileLocation: String?
	let profileUrl: URL?
}

extension TempUser: ImmutableMappable {
	
	init(map: Map) throws {
		id = try? map.value("user.id")
		name = try? map.value("user.name")
		screenName = try? map.value("user.screen_name")
		isVerified = try? map.value("user.verified")
		profileImageUrl = try? map.value("user.profile_image_url", using: URLTransform())
		profileBannerUrl = try? map.value("profile_banner_url", using: URLTransform())
		profileBackgroundImageUrl = try? map.value("user.profile_background_image_url", using: URLTransform())
		followersCount = try? map.value("user.followers_count")
		friendsCount = try? map.value("user.friends_count")
		description = try? map.value("user.description")
		details = try? User.Details(map: map)
		seal = try? map.value("user.seal")
		profileLocation = try? map.value("location")
		profileUrl = try? map.value("entities.url.urls.0.display_url", using: URLTransform())
		expandedUrl = try? map.value("entities.url.urls.0.expanded_url", using: URLTransform())
	}
}
