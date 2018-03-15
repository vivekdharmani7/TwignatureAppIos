//
//  ChatsInteractor.swift
//  Twignature
//
//  Created by Anton Muratov on 9/14/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

class ChatsInteractor: BaseInteractor {
    weak var presenter: ChatsPresenter!
	
	private lazy var chatService = ChatsService()

    func loadChats(completion: @escaping ResultClosure<[Conversation]>) {
		guard let currentUser = Session.current?.user else {
			let errorResult: Result<[Conversation]> = Result.failure(TwignatureError.accessDenied)
			completion(errorResult)
			return
		}
		
		chatService.loadChats(count: 100, sinceId: nil, maxId: nil) { result in
			switch result {
			case .success(let messages):
				let conversations = Conversation.groupByUsers(userID: currentUser.id, messages: messages)
				let convResult = Result.success(conversations)
				completion(convResult)
			case .failure(let error):
				let errorResult: Result<[Conversation]> = Result.failure(error)
				completion(errorResult)
			}
		}
    }
}
