//
//  NetworkService.swift
//  Twignature
//
//  Created by Ivan Hahanov on 8/31/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import Networking
import TwitterKit
import ReachabilitySwift
import ObjectMapper

final class NetworkService: RequestService {
    private var requestID: String?
    private var serverApiClient: Networking
    private lazy var twitterApiClient = Session.current!.twitterApiClient
    private let twitterBaseUrl = "https://api.twitter.com/1.1/"
	private let twitterUploadUrl = "https://upload.twitter.com/1.1/"
    private let reachability = Reachability()
    
    var didChangeState: ((RequestState) -> Void)?
    var state: RequestState = .pending {
        didSet {
            didChangeState?(state)
        }
    }
    
    static var environment: Environment = .production
    
    required init() {
        serverApiClient = Networking(baseURL: NetworkService.environment.url)
    }
	
    // MARK: - Nested entities
    
    enum Environment {
        case staging
        case production
		
		var domen: String {
			switch self {
			case .staging: return "http://seal.twignature.com:8080"
			case .production: return "https://seal.twignature.com"
			}
		}
		
        var url: String {
			return domen + "/api/v1/"
        }
		
		var imagesUrl: String {
			return domen
		}
		
		var linksUrl: String {
			return domen + "/web/tweets/"
		}
    }
    
    // MARK: - Actions
	
    func fetch<Resource: JSONRequest>(resource: Resource,
               completion: @escaping ResultClosure<Resource.Model>) {
        guard reachability?.isReachable ?? false else {
            completion(.failure(TwignatureError.noInternetConnection))
            return
        }
        switch resource.host {
        case .twitter:
            fetchForTwitter(resource: resource, completion: completion)
        case .server:
            fetchForServer(resource: resource, completion: completion)
		case .twitterUpload:
			fetchForTwitterUpload(resource: resource, completion: completion)
			
        }
    }
    
    func fetch<Resource: JSONRequest>(resource: Resource,
                                      completion: @escaping ResultClosure<Resource.Model>) where Resource.Model : SearchForTweetsResultProtocol {
        guard reachability?.isReachable ?? false else {
            completion(.failure(TwignatureError.noInternetConnection))
            return
        }

		switch resource.host {
		case .twitter, .twitterUpload:
			fetchForTwitter(resource: resource, completion: completion)
		case .server:
			fetchForServer(resource: resource, completion: completion)
		}
    }
    
    func filteringArrayTweetsClosure(completion: @escaping ResultClosure<[Tweet]>) -> ResultClosure<[Tweet]> {
		return completion
    }
    
    func fetchArrayOfTweets<Resource: JSONRequest>(resource: Resource,
                                              completion: @escaping ResultClosure<[Resource.Model]>) where Resource.Model == Tweet {
		switch resource.host {
		case .twitter, .twitterUpload:
			fetchArrayForTwitter(resource: resource, completion: completion)
		case .server:
			fetchArrayForServer(resource: resource, completion: completion)
		}
    }
    
    func fetchArray<Resource: JSONRequest>(resource: Resource,
                                           completion: @escaping ResultClosure<[Resource.Model]>) {
        guard reachability?.isReachable ?? false else {
            completion(.failure(TwignatureError.noInternetConnection))
            return
        }
		
        switch resource.host {
        case .twitter, .twitterUpload:
            fetchArrayForTwitter(resource: resource, completion: completion)
        case .server:
            fetchArrayForServer(resource: resource, completion: completion)
        }
    }
    
    func cancelRequest() {
        if let id = requestID {
            serverApiClient.cancel(id)
            requestID = nil
            state = .cancelled
        }
    }
    
    // MARK: - Private
    
    private func fetchForTwitter<Resource: JSONRequest>(resource: Resource,
                                 completion: @escaping ResultClosure<Resource.Model>) {
        performTwitterRequest(resource: resource) { [weak self] result in
            switch result {
            case .success(let data):
                guard let json = data as? [String: Any] else {
					self?.handleTwitterResult(resource: resource, result: .success([String: Any]()), completion: completion)
					return
				}
                self?.handleTwitterResult(resource: resource, result: .success(json), completion: completion)
            case .failure(let error):
                self?.handleTwitterResult(resource: resource, result: .failure(error), completion: completion)
            }
        }
    }
	
	private func fetchForTwitterUpload<Resource: JSONRequest>(resource: Resource,
	                             completion: @escaping ResultClosure<Resource.Model>) {
		performTwitterUploadRequest(resource: resource) { [weak self] result in
			switch result {
			case .success(let data):
				guard let json = data as? [String: Any] else { fatalError("Invalid response") }
				self?.handleTwitterResult(resource: resource, result: .success(json), completion: completion)
			case .failure(let error):
				self?.handleTwitterResult(resource: resource, result: .failure(error), completion: completion)
			}
		}
	}
	
    private func fetchArrayForTwitter<Resource: JSONRequest>(resource: Resource,
                                 completion: @escaping ResultClosure<[Resource.Model]>) {
        performTwitterRequest(resource: resource) { [weak self] result in
            switch result {
            case .success(let data):
                guard let array = data as? [[String: Any]] else { fatalError("Invalid response") }
                self?.handleTwitterResult(resource: resource, result: .success(array), completion: completion)
            case .failure(let error):
                self?.handleTwitterResult(resource: resource, result: .failure(error), completion: completion)
            }
        }
    }
    
    private func fetchForServer<Resource: JSONRequest>(resource: Resource,
                                     completion: @escaping ResultClosure<Resource.Model>) {
        performServerRequest(resource: resource) { [weak self] result in
            self?.handleServerResult(resource: resource, result: result, completion: completion)
        }
    }
    
    private func fetchArrayForServer<Resource: JSONRequest>(resource: Resource,
                                completion: @escaping ResultClosure<[Resource.Model]>) {
        performServerRequest(resource: resource) { [weak self] result in
            self?.handleServerResult(resource: resource, result: result, completion: completion)
        }
    }
	
	private func performTwitterUploadRequest<Resource: JSONRequest>(resource: Resource,
	                                   completion: @escaping ResultClosure<Any>) {
		var error: NSError?
		let request = twitterApiClient.urlRequest(withMethod: resource.method.rawValue,
		                                          url: twitterUploadUrl + resource.path,
		                                          parameters: resource.parameters,
		                                          error: &error)
		twitterApiClient.sendTwitterRequest(request) { (_, data, error) in
			if let data = data {
				let json = try? JSONSerialization.jsonObject(with: data)
				completion(.success(json!))
			} else if let error = error {
				completion(.failure(error))
				return
			}
		}
	}
	
    private func performTwitterRequest<Resource: JSONRequest>(resource: Resource,
                                       completion: @escaping ResultClosure<Any>) {
        var error: NSError?
        var request = twitterApiClient.urlRequest(withMethod: resource.method.rawValue,
                                                  url: twitterBaseUrl + resource.path,
                                                  parameters: resource.parameters,
                                                  error: &error)
		if let httpBody = resource.httpBody {
			request.httpBody = httpBody
			request.setValue("application/json", forHTTPHeaderField: "Accept")
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.setValue(String(httpBody.count), forHTTPHeaderField: "Content-Length")
		}
		
        twitterApiClient.sendTwitterRequest(request) { (_, data, error) in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data)
                completion(.success(json!))
            } else if let error = error {
                completion(.failure(error))				
                return
            }
        }
    }
    
    private func performServerRequest<Resource: JSONRequest>(resource: Resource,
                                      completion: @escaping Closure<JSONResult>) {
        state = .executing
        serverApiClient.headerFields = resource.headers
        if let parts = resource.parts {
            requestID = serverApiClient.post(resource.path, parts: parts, completion: completion)
        }
        
        switch resource.method {
        case .post:
            requestID = serverApiClient.post(resource.path,
                                             parameterType: resource.parameterEncoding,
                                             parameters: resource.parameters ?? [:],
                                             completion: completion)
        case .get:
            requestID = serverApiClient.get(resource.path, parameters: resource.parameters,
                                            completion: completion)
        case .delete:
            requestID = serverApiClient.delete(resource.path, completion: completion)
        case .put:
            requestID = serverApiClient.put(resource.path,
                                            parameterType: resource.parameterEncoding,
                                            parameters: resource.parameters ?? [:],
                                            completion: completion)
        }
    }
    
    private func handleServerResult<Resource: JSONRequest>(resource: Resource,
                result: JSONResult,
                completion: @escaping ResultClosure<Resource.Model>) {
        switch result {
        case .success(let response):
            debugPrint(response)
            completion(resource.parse(json: response.dictionaryBody))
        case .failure(let response):
            debugPrint(response)
            if resource.shouldBeAuthorized {
                if response.statusCode == ErrorCode.unauthorized {
                    notifySessionExpired()
                }
            }
            completion(.failure(resource.parseError(json: response.dictionaryBody) ?? response.error))
        }
        state = .finished
    }
    
    private func handleServerResult<Resource: JSONRequest>(resource: Resource,
                        result: JSONResult,
                        completion: @escaping ResultClosure<[Resource.Model]>) {
        switch result {
        case .success(let response):
            debugPrint(response)
            completion(resource.parse(jsonArray: response.arrayBody))
        case .failure(let response):
            debugPrint(response)
            if resource.shouldBeAuthorized {
                if response.statusCode == ErrorCode.unauthorized {
                    notifySessionExpired()
                }
            }
            completion(.failure(resource.parseError(json: response.dictionaryBody) ?? response.error))
        }
        state = .finished
    }
    
    private func handleTwitterResult<Resource: JSONRequest>(resource: Resource,
                                    result: Result<[String: Any]>,
                                    completion: @escaping ResultClosure<Resource.Model>) {
        switch result {
        case .success(let json):
            completion(resource.parse(json: json))
        case .failure(let error):
            debugPrint(error)
            if resource.shouldBeAuthorized {
                if (error as NSError).code == ErrorCode.unauthorized {
                    notifySessionExpired()
                }
            }
            let nextError: NSError = error as NSError
            if nextError.domain == TWTRAPIErrorDomain,
                let failureReason = nextError.localizedFailureReason,
                let errorStartRange = failureReason.range(for: "Twitter API error : "),
                let errorEndRange = failureReason.range(for: "code") {
                let startIndex = failureReason.index(failureReason.startIndex, offsetBy: errorStartRange.upperBound)
                let endIndex = failureReason.index(failureReason.startIndex, offsetBy: errorEndRange.lowerBound - 1)
                let range = startIndex..<endIndex
                let errorMessage = failureReason.substring(with: range)
                let twitterError = TwignatureError.twitterError(message: errorMessage, code: nextError.code)
                completion(.failure(twitterError))
                return
            }
            completion(.failure(error))
        }
        state = .finished
    }
    
    private func handleTwitterResult<Resource: JSONRequest>(resource: Resource,
                                     result: Result<[[String: Any]]>,
                                    completion: @escaping ResultClosure<[Resource.Model]>) {
        switch result {
        case .success(let array):
            completion(resource.parse(jsonArray: array))
        case .failure(let error):
            debugPrint(error)
            if resource.shouldBeAuthorized {
                if (error as NSError).code == ErrorCode.unauthorized {
                    notifySessionExpired()
                }
            }
            let nextError: NSError = error as NSError
            if nextError.domain == TWTRAPIErrorDomain,
                let failureReason = nextError.localizedFailureReason,
                let errorStartRange = failureReason.range(for: "Twitter API error : "),
                let errorEndRange = failureReason.range(for: "code") {
                let startIndex = failureReason.index(failureReason.startIndex, offsetBy: errorStartRange.upperBound)
                let endIndex = failureReason.index(failureReason.startIndex, offsetBy: errorEndRange.lowerBound - 1)
                let range = startIndex..<endIndex
                let errorMessage = failureReason.substring(with: range)
                let twitterError = TwignatureError.twitterError(message: errorMessage, code: nextError.code)
                completion(.failure(twitterError))
                return
            }
            completion(.failure(error))
        }
        state = .finished
    }
    
    private func notifySessionExpired() {
        let notificationName = NSNotification.Name(rawValue: NotificationIdentifier.SessionExpired)
        NotificationCenter.default.post(name: notificationName, object: nil)
    }
}
