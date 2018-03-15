//
//  ProviderAuthorizer.swift
//  PledgeFit
//
//  Created by Ivan Hahanov on 8/7/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation

protocol Authorizer {
    var isAuthorized: Bool { get }
    var accessToken: String? { get }
    
    func login(completion: @escaping Closure<AuthorizationResult>)
}

enum AuthorizationResult {
    case success, failure(Error), cancelled
}

class ProviderAuthorizer {
    static func facebook(permissions: [FacebookManager.FacebookPermsission]) -> Authorizer {
        let facebookManager = FacebookManager()
        facebookManager.permissions = permissions
        return facebookManager
    }
    
    static var twitter: Authorizer {
        return TwitterManager()
    }
}
