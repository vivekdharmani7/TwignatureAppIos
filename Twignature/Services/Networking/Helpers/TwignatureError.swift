//
//  TwignatureErrors.swift
//  Twignature
//
//  Created by mac on 13.09.17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

enum TwignatureError {
	case twitterAccountNotFound
	case unauthorized
	case accessDenied
	case maximumCharactersLimit
	case signatureNotAttached
	case messageWasNotDelivered
	case unexpectedResult
    case noInternetConnection
    case allFieldsAreMandory
    case twitterError(message: String, code: Int)
}

extension TwignatureError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case .twitterAccountNotFound:
			return R.string.twignatureError.twitterAccountNotFound()
		case .unauthorized:
			return R.string.twignatureError.unauthorized()
		case .accessDenied:
			return R.string.twignatureError.accessDenied()
		case .maximumCharactersLimit:
			return R.string.twignatureError.maximumCharactersLimit()
		case .signatureNotAttached:
			return R.string.twignatureError.signatureNotAttached()
		case .messageWasNotDelivered:
			return R.string.twignatureError.messageWasNotDelivered()
		case .unexpectedResult:
			return R.string.twignatureError.unexpectedResult()
        case .noInternetConnection:
            return R.string.twignatureError.noInternet()
        case .allFieldsAreMandory:
            return R.string.twignatureError.allFieldsAreMandory()
        case .twitterError(let message, _):
            return message
		}
	}
}
