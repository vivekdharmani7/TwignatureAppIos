//
//  ChatsService.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/28/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
final class ChatsService {
	
	private lazy var networkService: RequestService = NetworkService()
	
	func loadChats(count: Int?,
	               sinceId: TwitterId?,
	               maxId: TwitterId?,
	               completion: @escaping ResultClosure<[Message]>) {
		let sentRequest = Request.Chats.MessagesSent(count: count, sinceId: sinceId, maxId: maxId)
		let receivedRequest = Request.Chats.MessagesReceived(count: count, sinceId: sinceId, maxId: maxId)
		
		let group = DispatchGroup()
		var results = [Result<[Message]>] ()
		
		group.enter()
		group.enter()
		
		networkService.fetchArray(resource: sentRequest) { result in
			results.append(result)
			group.leave()
		}
		
		networkService.fetchArray(resource: receivedRequest) { result in
			results.append(result)
			group.leave()
		}
		
		group.notify(queue: .main) {
			var items = [Message]()
			for result in results {
				switch result {
				case .success(let newItems):
					items.append(contentsOf: newItems)
				case .failure:
					completion(result)
					return
				}
			}
			
			let sortedItems = items.sorted { $0.0.createdAt > $0.1.createdAt }
			let combinedResult = Result<[Message]>.success(sortedItems)
			
			completion(combinedResult)
		}
	}
}
