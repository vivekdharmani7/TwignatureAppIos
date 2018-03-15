//
//  UserListViewModel.swift
//  Twignature
//
//  Created by Ivan Hahanov on 10/12/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

extension UserListViewController {
    struct UserViewModel {
        let id: TwitterId
        let name: String
        let screenName: String
        var isVerified: Bool
        let avatarUrl: URL?
        var buttonCallback: Closure<Void>?
        var selectionClosure: Closure<Void>?
        
        init(user: User, selectionClosure: Closure<Void>? = nil, buttonCallback: Closure<Void>? = nil) {
            self.id = user.id
            self.name = user.name
            self.screenName = "@\(user.screenName) "
            self.avatarUrl = user.profileImageUrl
            self.isVerified = user.isVerified
            self.buttonCallback = buttonCallback
            self.selectionClosure = selectionClosure
        }
    }
}
