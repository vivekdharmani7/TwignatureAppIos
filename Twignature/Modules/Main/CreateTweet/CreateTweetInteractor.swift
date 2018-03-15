//
//  CreateTweetInteractor.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/12/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation
import LocalAuthentication

enum AttachmentTweetRole {
	case reply
	case retweet
}

class CreateTweetInteractor: BaseInteractor {
    weak var presenter: CreateTweetPresenter!
    
    private var page: Int?
    private var query: String?
	
	func getHelpConfiguration() {
		
	}
	
	func createTwignatureReference(_ completion: @escaping ResultClosure<Identifier>) {
		let request = Request.Tweets.CreateTweetRef()
		networkService.fetch(resource: request, completion: completion)
	}
	
	func updateCurrentUserInfo(_ completion: @escaping ResultClosure<TempUser>) {
		let request = Request.Users.Current()
		networkService.fetch(resource: request, completion: completion)
	}
	
    func searchUsers(query: String, completion: @escaping ResultClosure<[User]>) {
        debounce(sec: 0.5) { [weak self] in
            if query == self?.query { return }
            self?.loadUsers(query: query, page: 0, completion: { (result) in
                switch result {
                case .success(let users):
                    let sortedUsers = users.sorted(by: { (first, second) -> Bool in
                        if let firstFollowing = first.following, firstFollowing {
                            if let secondFollowing = second.following, secondFollowing {
                                return first.followersCount > second.followersCount
                            }
                            return first.following != nil
                        }
                        return first.followersCount > second.followersCount
                    })
                    completion(.success(sortedUsers))
                case .failure(let error):
                    completion(.failure(error))
                    break
                }
            })
        }
    }
    
    func loadMoreUsers(completion: @escaping ResultClosure<[User]>) {
        guard let page = page, let query = query else { return }
        loadUsers(query: query, page: page + 1, completion: completion)
    }
    
    private func loadUsers(query: String, page: Int, completion: @escaping ResultClosure<[User]>) {
        self.query = query
        self.page = page
        let request = Request.Users.Search(query: query, page: page)
        networkService.fetchArray(resource: request, completion: completion)
    }
    
    func finishSearch() {
        page = nil
        query = nil
        workItem.cancel()
    }
	
	func uploadMedia(_ image: UIImage, completion: @escaping ResultClosure<TwitterMedia>) {
		let request = Request.Tweets.UploadMedia(image: image)
		networkService.fetch(resource: request) { result in
			switch result {
			case .success(let media):
				completion(.success(media))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
	
	func addUploadingOperationsOfMedia(_ media: Media?,
	                                   operationQueue: OperationQueue,
	                                   completion: @escaping ResultClosure<TwitterMedia> ) -> NetworkOperation<Request.Tweets.UploadMedia, NetworkService>? {
		var lastMediaOperation:NetworkOperation<Request.Tweets.UploadMedia, NetworkService>?
		if let media = media {
			switch media {
			case .photos(let images):
				for image in images {
					let request = Request.Tweets.UploadMedia(image: image)
					let operation = NetworkOperation<Request.Tweets.UploadMedia, NetworkService>(request: request, completion: completion)
					if let lastMediaOperation = lastMediaOperation {
						operation.addDependency(lastMediaOperation)
					}
					lastMediaOperation = operation
					operationQueue.addOperation(operation)
				}
			default: break
			}
		}
		return lastMediaOperation
	}
	
	private func registerTweetWithSeal(_ tweet: Tweet,
	                                   and reference: Identifier,
	                                   completion: @escaping ResultClosure<Void>) {
		let request = Request.Tweets.CreateOnTwignature(tweet.id, tweetRef: reference.id)
		networkService.fetch(resource: request) { result in
			switch result {
			case .failure(let error):
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			case .success:
				DispatchQueue.main.async {
					completion(.success())
				}
			}
		}
	}
	
	private func createTweetWithMedia(text: String,
									  location: Location?,
									  media: [TwitterMedia]?,
									  attachedTweet: Tweet? = nil,
									  attachedTweetRole: AttachmentTweetRole? = nil,
									  withSeal: Bool,
									  andReference: Identifier?,
									  completion: @escaping ResultClosure<Void>
	                                 ) {
		
		let createTweetRequest = Request.Tweets.Create(text: text,
		                                               location: location,
		                                               media: media,
		                                               twitterReference:  andReference?.id,
		                                               attachedTweet: attachedTweet,
		                                               attachedTweetRole: attachedTweetRole)
		networkService.fetch(resource: createTweetRequest) { [weak self] result in
			switch result {
			case .failure(let error):
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			case .success(let tweet):
				if withSeal, let reference = andReference {
					self?.registerTweetWithSeal(tweet,
					                            and: reference,
					                            completion: completion)
				} else {
					DispatchQueue.main.async {
						completion(.success())
					}
				}
			}
		}
	}
	
	func createTweet(text: String,
					 location: Location?,
					 media: Media?,
					 attachedTweet: Tweet?,
					 withRole: AttachmentTweetRole,
					 withSeal: Bool,
					 andReference: Identifier?,
					 completion: @escaping ResultClosure<Void>) {
		
		guard let media = media else {
			createTweetWithMedia(text: text,
			                     location: location,
			                     media: nil,
			                     attachedTweet: attachedTweet,
			                     attachedTweetRole: withRole,
			                     withSeal: withSeal,
			                     andReference: andReference,
			                     completion: completion)
			return
		}
		
		//media attachments
		DispatchQueue.global().async { [weak self] in
			guard let operationQueue = self?.operationQueue else {
				return
			}
			var resultMediaItems: [TwitterMedia] = []
			//MEDIA
			_ = self?.addUploadingOperationsOfMedia(media, operationQueue: operationQueue, completion: { result in
				switch result {
				case .success(let media):
					resultMediaItems.append(media)
					guard operationQueue.operations.isEmpty else {
						return
					}
					self?.createTweetWithMedia(text: text,
					                           location: location,
					                           media: resultMediaItems,
					                           attachedTweet: attachedTweet,
					                           attachedTweetRole: withRole,
					                           withSeal: withSeal,
					                           andReference: andReference,
					                           completion: completion)
				case .failure(let error):
					DispatchQueue.main.async { [weak self] in
						self?.operationQueue.cancelAllOperations()
						completion(.failure(error))
					}
				}
			})
		}
		operationQueue.waitUntilAllOperationsAreFinished()
    }
    
    func authenticateUser(completion: @escaping ResultClosure<Void>) {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else { return }
        context.evaluatePolicy(.deviceOwnerAuthentication,
                               localizedReason: R.string.tweets.authenticationReason()) { success, error in
                                if success {
                                    DispatchQueue.main.async {
                                        completion(.success())
                                    }
                                } else {
                                    print(error!.localizedDescription)
                                    switch (error! as NSError).code {
                                        
                                    case LAError.systemCancel.rawValue:
                                        print("Authentication was cancelled by the system")
                                        
                                    case LAError.userCancel.rawValue:
                                        print("Authentication was cancelled by the user")
                                        
                                    case LAError.userFallback.rawValue:
                                        print("User selected to enter custom password")
                                        
                                    default:
                                        DispatchQueue.main.async {
                                            completion(.failure(error!))
                                        }
                                    }
                                }
        }
    }
}
