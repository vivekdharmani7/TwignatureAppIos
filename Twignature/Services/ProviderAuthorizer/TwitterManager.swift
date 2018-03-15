//
//  TwitterManager.swift
//  Twignature
//
//  Created by Ivan Hahanov on 8/29/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import TwitterKit

class TwitterManager {
}

extension TwitterManager: Authorizer {
    var isAuthorized: Bool {
        return Twitter.sharedInstance().sessionStore.session() != nil
    }
    
    var accessToken: String? {
        return Twitter.sharedInstance().sessionStore.session()?.authToken
    }
    
    func login(completion: @escaping (AuthorizationResult) -> Void) {
        Twitter.sharedInstance().logIn { session, error in
            if session != nil {
                completion(.success)
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}
