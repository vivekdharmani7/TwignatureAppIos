//
//  DrawSession.swift
//  Twignature
//
//  Created by Ivan Hahanov on 8/31/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import TwitterKit

class Session {
    private(set) var user: User
    let token: String
    let secretToken: String
	private(set) var twitterApiClient: TWTRAPIClient
	fileprivate lazy var networkService: RequestService = NetworkService()
	
    init(token: String, secretToken: String, user: User) {
        self.token = token
        self.secretToken = secretToken
        self.user = user
		twitterApiClient = TWTRAPIClient(userID: user.id)
    }
	
	func updateSessionProfileImagePath(_ path: String) {
		
	}
	
	func updateSessionWithTempUser(_ user: TempUser) {
		self.user.mergeTemporaryUser(user)
	}
	
	func updateSessionWithUser(_ user: User) {
		self.user.mergeUser(user)
	}
	
    func updateSessionSensetive() {
        let request = Request.Users.UserSettings()
        networkService.fetch(resource: request) { [weak self] (result) in
            switch result {
            case .success(let settings):
                self?.user.shouldDisplaySensetiveContent = settings.displaySensitiveMedia
                break
            case .failure: break
            }
        }
    }
    
    static var current: Session?
    
    static var isAuthorized: Bool {
        return Twitter.sharedInstance().sessionStore.session() != nil
    }
    
    static func logout() throws {
        guard let id = Twitter.sharedInstance().sessionStore.session()?.userID else {
            throw Error.unauthorized
        }
        Twitter.sharedInstance().sessionStore.logOutUserID(id)
    }
    
    static func restore(completion: ResultClosure<Void>? = nil) {
        guard let token = Twitter.sharedInstance().sessionStore.session()?.authToken,
            let secretToken = Twitter.sharedInstance().sessionStore.session()?.authTokenSecret,
            let id = Twitter.sharedInstance().sessionStore.session()?.userID else {
            completion?(.failure(Error.unauthorized))
            return
        }
        TWTRAPIClient.withCurrentUser().loadUser(withID: id) { twitterUser, error in
			guard let twitterUser = twitterUser else {
				let error = error ?? TwignatureError.twitterAccountNotFound
				let errorResult: Result<Void> = Result.failure(error)
				completion?(errorResult)
				return
			}
			
			self.twitterUserDidFetch(token: token, secretToken: secretToken, twitterUser: twitterUser, completion: completion)
        }
            
    }
	
	private static func twitterUserDidFetch(token: String,
	                                        secretToken: String,
	                                        twitterUser: TWTRUser,
	                                        completion: ResultClosure<Void>?) {
		let user = User(twitterUser: twitterUser)
		current = Session(token: token, secretToken: secretToken, user: user)
	
		let request = Request.Users.Auth(userId: user.id,
		                                 twitterSecret: secretToken,
                                         pushToken: UserDefaults.standard.string(forKey: Key.pushTokenKey))
		current?.networkService.fetch(resource: request) { result in
			switch result {
			case .success(let user):
				current?.updateSessionWithTempUser(user)
				completion?(.success())
				break
			case .failure(let error):
				completion?(.failure(error))
			}
		}
	}
    
    enum Error: LocalizedError {
        case unauthorized
    }
}
