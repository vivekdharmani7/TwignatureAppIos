//
//  RequestVerificationInteractor.swift
//  Twignature
//
//  Created by mac on 01.11.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

class RequestVerificationInteractor: BaseInteractor {
    weak var presenter: RequestVerificationPresenter!
    
    func submitVerification(WithMessage message: String,
                            phone: String,
                            email: String,
                            name: String,
                            completion: @escaping ResultClosure<OptionalModel>) {
        do {
            try Validator.emptiness(value: name)
            try Validator.emptiness(value: message)
            try Validator.phoneNumber(value: phone)
            try Validator.email(value: email)
        } catch {
            completion(.failure(error))
            return
        }
        let request = Request.Users.RequestVerification(withMessage: message,
                                                        phone: phone,
                                                        email: email,
                                                        name: name)
        networkService.fetch(resource: request, completion: completion)
    }
}
