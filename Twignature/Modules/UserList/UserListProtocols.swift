//
//  UserListProtocols.swift
//  Twignature
//
//  Created by Ivan Hahanov on 10/11/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

protocol UserListCoordinator: class, BaseCoordinator {
    func showUserProfile(userId: String, userScreenName: String)
}
