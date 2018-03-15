//
//  ProfileViewModel.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/11/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

extension ProfileViewController {
    
    enum Section {
		case description
        case details(rows: [FloatingTitledCell.ViewModel])
        case media(title: String, items: [MediaItem])
        
        static var count: Int {
            return 3
        }
    }
    
    struct Details {
        let following: Int
        let followers: Int
        let mentions: Int
        let likes: Int
        let tweets: Int
        
        init(details: User.Details) {
            following = details.followingCount
            followers = details.followersCount
            mentions = 0
            likes = details.likesCount
            tweets = details.tweetsCount
        }
    }
    
    struct HeaderViewModel {
        let name: String
        let screenName: String
        let description: String?
        let location: String?
        let avatarUrl: URL?
        let backgroundUrl: URL?
        let isVerified: Bool
		let profileUrlDisplay: String?
        
        init(user: User) {
            self.name = user.name
            self.screenName = "@\(user.screenName)"
            self.avatarUrl = user.profileImageUrlOriginal
            self.backgroundUrl = user.profileBackgroundImageUrl ?? user.profileBannerUrl
            self.location = user.details?.location
            self.isVerified = user.isVerified
            self.description = user.description
			self.profileUrlDisplay = user.profileUrl?.absoluteString
        }
    }
}
