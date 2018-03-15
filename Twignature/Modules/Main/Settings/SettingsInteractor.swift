//
//  SettingsInteractor.swift
//  Twignature
//
//  Created by mac on 12.10.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

class SettingsInteractor: BaseInteractor {
    weak var presenter: SettingsPresenter!
	
	func fetchCurrentUserInfo(_ completion: @escaping ResultClosure<User>) {
		guard let user = Session.current?.user else {
			completion(.failure(TwignatureError.unauthorized))
			return
		}
		let request = Request.Users.Details(userId: user.id, screenName: user.screenName)
		networkService.fetch(resource: request, completion: completion)
	}
    
    func fetchAccountSettings(_ completion: @escaping ResultClosure<UserSetting>) {
        let request = Request.Users.UserSettings()
        networkService.fetch(resource: request, completion: completion)
    }
	
	func updateUserWith(name: String?,
						url: String?,
						location: String?,
						description: String?,
						displaySensitiveContent: Bool?,
						completion: @escaping ResultClosure<User>) {
		//validator
		if let error = validateUserUpdate(name: name,
		                                  url: url) {
			completion(.failure(error))
			return
		}
		//request
		let request = Request.Users.Update(name: name,
		                                   url: url,
		                                   location: location,
		                                   userDescription: description)
        guard let sensetive = displaySensitiveContent else {
            networkService.fetch(resource: request, completion: completion)
            return
        }
        let sensetiveRequest = Request.Users.UpdateUserSettings(withShoudDisplaySensetive: sensetive)
        networkService.fetch(resource: sensetiveRequest) { [weak self] (result) in
            switch result {
            case .success:
                self?.networkService.fetch(resource: request, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
	}
	
	func validateUserUpdate(name: String?,
	                        url: String?) -> Error? {
		do {
			if let url = url { try Validator.url(value: url) }
			if let name = name { try Validator.emptiness(value: name) }
		} catch {
			return error
		}
		return nil
	}
	
}
