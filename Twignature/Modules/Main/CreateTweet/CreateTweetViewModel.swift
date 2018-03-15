//
//  CreateTweetViewModel.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/14/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

extension CreateTweetViewController {
    struct UserViewModel {
        let name: String
        let screenName: String
        let isVerified: Bool
        let avatarUrl: URL?
        
        init(user: User) {
            self.name = user.name
            self.screenName = user.screenName
            self.avatarUrl = user.profileImageUrl
            self.isVerified = user.isVerified
        }
    }
}
