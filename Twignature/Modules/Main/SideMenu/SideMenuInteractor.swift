//
//  SideMenuInteractor.swift
//  Twignature
//
//  Created by mac on 05.10.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation
import TwitterKit

class SideMenuInteractor: BaseInteractor {
    weak var presenter: SideMenuPresenter!
	
	func updateCurrentUserInfo(_ completion: @escaping ResultClosure<User>) {
		guard let currentUser = Session.current?.user else {
			return
		}
		let request = Request.Users.Details(userId: currentUser.id, screenName: currentUser.screenName)
		networkService.fetch(resource: request, completion: completion)
	}
    
    func performLogout(_ completion: @escaping ResultClosure<OptionalModel>) {
        let request = Request.Users.Logout()
        networkService.fetch(resource: request, completion: completion)
    }
}
