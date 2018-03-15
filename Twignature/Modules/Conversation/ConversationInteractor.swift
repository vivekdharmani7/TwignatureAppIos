//
//  ConversationInteractor.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/29/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

class ConversationInteractor: BaseInteractor {
	weak var presenter: ConversationPresenter!
	var receiver: User?
	private lazy var chatService = ChatsService()
	
	func sendMessage(_ text: String, image: UIImage?) {
		guard let image = image else {
			sendMessageEvent(text, media: nil)
			return
		}
		
		uploadImage(image) { [weak self] result in
			switch result {
			case .success(let media):
				self?.sendMessageEvent(text, media: media)
			case .failure(let error):
				self?.presenter.sendingEndedWithError(error)
			}
		}
	}
	
	private func sendMessageEvent(_ text: String, media: TwitterMedia?) {
		guard let receiver = receiver else { return }
		let resource = Request.Chats.SendMessage(userId: receiver.id,
		                                     screenName: receiver.screenName,
		                                     text: text, media: media)
		
		networkService.fetch(resource: resource) { [weak self] result in
			switch result {
			case .success:
				self?.presenter.messageDidSent()
			case .failure(let error):
				self?.presenter.sendingEndedWithError(error)
			}
		}
	}
	
	private func uploadImage(_ image: UIImage, completion: @escaping ResultClosure<TwitterMedia>) {
		var imageToSend = image
		let maxH: CGFloat = 320
		if image.size.width > maxH || image.size.height > maxH {
			imageToSend = image.scaleToFitSize(CGSize(width: maxH, height: maxH))
		}
		
		let request = Request.Tweets.UploadMedia(image: imageToSend, compression: 0.7)
		networkService.fetch(resource: request) { result in
			switch result {
			case .success(let media):
				completion(.success(media))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
	
	func loadNew(sinceId: TwitterId?, completion: @escaping ResultClosure<[Message]>) {
		guard let currentUser = Session.current?.user, let receiver = receiver else {
			return
		}
		
		chatService.loadChats(count: 20, sinceId: sinceId, maxId: nil) { result in
			switch result {
			case .success(let allMessages):
				let conversations = Conversation.groupByUsers(userID: currentUser.id, messages: allMessages)
				let currentConv = conversations.first(where: { $0.user == receiver })
				let messages = currentConv?.messages ?? []
				let filteredResult = Result<[Message]>.success(messages)
				completion(filteredResult)
			case .failure:
				completion(result)
			}
		}
	}
}
