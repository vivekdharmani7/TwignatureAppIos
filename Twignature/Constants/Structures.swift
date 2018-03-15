//
//  Common.swift
//  Twignature
//
//  Created by user on 5/11/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import UIKit.UIImage

typealias Closure<T> = (T) -> Void
typealias ReturnClosure<InputType, ReturnType> = (InputType) -> ReturnType
typealias ResultClosure<Value> = Closure<Result<Value>>

enum Method: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

/// Namespace of default structure types
enum Default {

    struct Row {
        let title: String
        let details: String?
        let image: UIImage?
        let action: Closure<Void>?
    }
    
    struct Section {
        let title: String?
        var rows: [Any]
    }
    
    struct Error: LocalizedError {
        
        let type: String?
        let message: String
        let statusCode: Int?
        
        var errorDescription: String? {
            return message
        }
        
        init(type: String? = nil, message: String, statusCode: Int? = nil) {
            self.type = type
            self.message = message
            self.statusCode = statusCode
        }
    }
}

enum Result<Value> {
    case success(Value)
    case failure(Swift.Error)
}

enum CommonError: LocalizedError {
    case unknown
    case invalidDictionary
}
