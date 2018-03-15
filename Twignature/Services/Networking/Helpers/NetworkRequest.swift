//
//  NetworkRequest.swift
//  Twignature
//
//  Created by Anton Muratov on 9/7/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import Networking

enum RequestState {
    case pending, executing, cancelled, finished
}

enum RequestDestionation {
    case twitter
	case twitterUpload
    case server
}

protocol NetworkRequest {
    var path: String { get }
    var parameters: [String : Any]? { get }
    var method: Method { get }
    var parameterEncoding: Networking.ParameterType { get }
    var parts: [FormDataPart]? { get }
    var shouldBeAuthorized: Bool { get }
    var host: RequestDestionation { get }
	var headers: [String: String]? { get }
	var httpBody: Data? { get }
}

extension NetworkRequest {
    var parameters: [String : Any]? { return nil }
    var method: Method { return .get }
    var parameterEncoding: Networking.ParameterType { return .json }
    var parts: [FormDataPart]? { return nil }
    var shouldBeAuthorized: Bool { return true }
    var host: RequestDestionation { return .twitter }
	var headers: [String: String]? {
		guard let token = Session.current?.token, shouldBeAuthorized else {
			return [:]
		}
		return [
			"Authorization": token
		]
	}
	var httpBody: Data? { return nil }
}

protocol JSONRequest: NetworkRequest, Parsing, ErrorParsing { }

protocol RequestService {
    var state: RequestState { get }
    var didChangeState: Closure<RequestState>? { get set }
    
    init()
    
    func fetch<Resource: JSONRequest>(resource: Resource, completion: @escaping ResultClosure<Resource.Model>)
    func fetchArray<Resource: JSONRequest>(resource: Resource, completion: @escaping ResultClosure<[Resource.Model]>)
    func cancelRequest()
}
