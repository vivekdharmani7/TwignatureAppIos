//
//  Parsing.swift
//  Twignature
//
//  Created by Ivan Hahanov on 8/31/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import Networking
import ObjectMapper

//enum JSONResult {
//    case success(SuccessJSONResponse)
//    case failure(FailureJSONResponse)
//    
//    public init(body: Any?, statusCode: Int, error: NSError?) {
//        var dictionaryBody: [String: Any] = [:]
//        var arrayBody: [[String: Any]] = [[:]]
//        
//        if let dictionary = body as? [String: Any] {
//            dictionaryBody = dictionary
//        } else if let array = body as? [[String: Any]] {
//            arrayBody = array
//        }
//        
//        if let error = error {
//            self = .failure(FailureJSONResponse(statusCode: statusCode, error: error))
//        } else {
//            self = .success(SuccessJSONResponse(statusCode: statusCode, dictionaryBody: dictionaryBody, arrayBody: arrayBody))
//        }
//    }
//}
//
//class BaseJSONResponse {
//    let statusCode: Int
//    let dictionaryBody: [String: Any]
//    let arrayBody: [[String: Any]]
//    
//    init(statusCode: Int, dictionaryBody: [String: Any] = [:], arrayBody: [[String: Any]] = [[:]]) {
//        self.statusCode = statusCode
//        self.dictionaryBody = dictionaryBody
//        self.arrayBody = arrayBody
//    }
//}
//
//class SuccessJSONResponse: BaseJSONResponse { }
//
//class FailureJSONResponse: BaseJSONResponse {
//    let error: NSError
//    
//    init(statusCode: Int, error: NSError) {
//        self.error = error
//        super.init(statusCode: statusCode)
//    }
//}

enum ParsingError: LocalizedError {
    case unmappable
    case dataNotFound
}

protocol ResourceType {
    associatedtype Model: ImmutableMappable
}

protocol Parsing: ResourceType {
    func parse(json: [String : Any]) -> Result<Model>
    func parse(jsonArray: [[String : Any]]) -> Result<[Model]>
}

protocol KeyBasedParsing: Parsing {
    var mappingKey: String { get }
}

extension KeyBasedParsing {
    func parse(json: [String : Any]) -> Result<Model> {
        guard let value = json[mappingKey] as? Model else {
            return .failure(ParsingError.unmappable)
        }
        return .success(value)
    }
}

protocol MapperParsing: Parsing {
//    associatedtype Model: ImmutableMappable
}

extension MapperParsing {
    func parse(json: [String : Any]) -> Result<Model> {
        guard let model = try? Model(JSON: json) else {
            return .failure(ParsingError.unmappable)
        }
        return .success(model)
    }
    
    func parse(jsonArray: [[String : Any]]) -> Result<[Model]> {
        guard let models = try? Mapper<Model>().mapArray(JSONArray: jsonArray) else {
            return .failure(ParsingError.unmappable)
        }
        return .success(models)
    }
}
