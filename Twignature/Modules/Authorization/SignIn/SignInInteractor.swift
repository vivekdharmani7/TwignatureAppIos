//
//  SignInInteractor.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/1/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation
import TwitterKit

class SignInInteractor: BaseInteractor {
    weak var presenter: SignInPresenter!
    
    fileprivate let authorizer = ProviderAuthorizer.twitter
    fileprivate let twitterManager = TwitterManager()
    
    func login(completion: @escaping ResultClosure<Void>) {
        authorizer.login { result in
            switch result {
            case .success:
                Session.restore(completion: completion)
            case .failure(let error):
                completion(.failure(error))
            default: ()
            }
        }
    }
}
