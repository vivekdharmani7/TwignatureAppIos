//
//  ErrorParsing.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/1/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

protocol ErrorParsing {
    func parseError(json: [String : Any]) -> Error?
}

extension ErrorParsing {
    func parseError(json: [String : Any]) -> Error? {
        guard let message = json["message"] as? String else { return nil }
        return TwignatureError.twitterError(message: message, code: 0)
    }
}

protocol APIErrorParsing {
    func parseError(json: [String : Any]) -> Error?
}

extension APIErrorParsing {
    func parseError(json: [String : Any]) -> Error? {
        return nil
    }
}
