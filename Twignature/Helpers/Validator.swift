//
//  Validator.swift
//  PledgeFit
//
//  Created by user on 5/13/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation

typealias Criteria = (String) throws -> Void

enum Validator {
    
    enum Error: LocalizedError {
        case empty
        case invalidEmail
		case invalidUrl
        case invalidPhoneNumber
		
		var errorDescription: String? {
			switch self {
			case .empty:
				return "This field cannot be empty"
			case .invalidEmail:
				return "You have entered invalid email"
			case .invalidUrl:
				return "You have entered invalid url"
            case .invalidPhoneNumber:
                return "You have entered invalid phone number"
			}
		}
    }

    static func emptiness(value: String) throws {
        if value.isEmpty {
            throw Error.empty
        }
    }

    static func phoneNumber(value: String) throws {
        try  self.emptiness(value: value)
        let phoneRegex = "\\+?\\d{1,4}?[-.\\s]?\\(?\\d{1,3}?\\)?[-.\\s]?\\d{1,4}[-.\\s]?\\d{1,4}[-.\\s]?\\d{1,9}"
        if !value.matches(regex: phoneRegex) {
            throw Error.invalidPhoneNumber
        }
    }
    
    static func email(value: String) throws {
        try self.emptiness(value: value)
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        if !value.matches(regex: emailRegEx) {
            throw Error.invalidEmail
        }
    }
	
	static func url(value: String) throws {
		//((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)(:\d*)?((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[.\!\/\\w]*))?)
		try self.emptiness(value: value)
		let urlRegex = "(((([A-Za-z]{3,9}:(?:\\/\\/)?)(?:[-;:&=\\+\\$,\\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\\+\\$,\\w]+@))?[A-Za-z0-9.-]+)((:\\d*)|(\\.\\w))+((?:\\/[\\+~%\\/.\\w-_]*)?\\??(?:[-\\+=&;%@.\\w_]*)#?(?:[.\\!\\/\\\\w]*)))$"
		if !value.matches(regex: urlRegex) {
			throw Error.invalidUrl
		}
	}
    
}

extension String {
    
    func validate(_ criteria: Criteria) throws {
        try criteria(self)
    }
    
    func validate(_ criterias: [Criteria]) -> [Error] {
        var errors: [Error] = []
        criterias.forEach { criteria in
            do {
                try criteria(self)
            } catch {
                errors.append(error)
            }
        }
        return errors
    }
}
