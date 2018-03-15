//
//  FacebookManager.swift
//  Twignature
//
//  Created by Ivan Hahanov on 8/29/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
//import FacebookCore
//import FacebookLogin

class FacebookManager: Authorizer {
    var isAuthorized: Bool {
        return false//AccessToken.current?.authenticationToken != nil
    }
    
    var accessToken: String? {
        return nil
    }
    
    var token: String? {
        return nil//AccessToken.current?.authenticationToken
    }
    
    var permissions: [FacebookPermsission] = []
    
    enum FacebookPermsission {
        
        case publicProfile
        case userFriends
        case email
        case custom(String)
        
//        var converted: ReadPermission {
//            switch self {
//            case .publicProfile:
//                return .publicProfile
//            case .userFriends:
//                return .userFriends
//            case .email:
//                return .email
//            case .custom(let value):
//                return .custom(value)
//            }
//        }
    }
    
    func login(completion: @escaping (AuthorizationResult) -> Void) {
        
    }
}
