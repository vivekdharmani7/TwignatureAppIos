//
//  ConversationPresenter.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/29/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Chatto
import ChattoAdditions
import ImagePicker

private let chatRefreshInterval: TimeInterval = 25

class ConversationPresenter {
	
	var initialMessage: String?
	
	var conversation: Conversation? {
		didSet {
			guard let conversation = conversation else {
				messages = []
				return
			}
			messages = conversation.messages
				.sorted(by: { $0.0.createdAt < $0.1.createdAt })
			interactor.receiver = conversation.user
		}
	}
	
	fileprivate var messages = [Message]()
	fileprivate var attachedImage: UIImage?
	
	//MARK: - Init
    required init(controller: ConversationViewController,
                  interactor: ConversationInteractor,
                  coordinator: ConversationCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
    }
	
	dynamic
	private func runTimedCode() {
		updateMessages()
	}
	
	func viewIsReady() {
		controller.avatarURL = conversation?.user.profileImageUrl
		controller.setChatDataSource(self, triggeringUpdateType: .firstLoad)
		controller.setMessageText(initialMessage)
	}
	
	func viewWillAppear() {
		if messages.isEmpty {
			updateMessages()
		}
		startTimer()
	}
	
	func viewWillDisapear() {
		stopTimer()
	}
	
	private var timer: Timer?
	
	private func startTimer() {
		stopTimer()
		timer = Timer.scheduledTimer(timeInterval: chatRefreshInterval,
		                             target: self,
		                             selector: #selector(runTimedCode),
		                             userInfo: nil, repeats: true)
	}
	
	private func stopTimer() {
		timer?.invalidate()
		timer = nil
	}
	
    fileprivate let coordinator: ConversationCoordinator
    fileprivate unowned var controller: ConversationViewController
    fileprivate var interactor: ConversationInteractor
	
	func backAction() {
		coordinator.back()
	}
	
	func pickImageAction() {
		let imagePicker = ImagePickerController()
		imagePicker.imageLimit = 1
		imagePicker.delegate = self
		controller.present(imagePicker, animated: true)
	}
	
	func sendMessageAction(_ text: String) {
		controller.showHUD()
		interactor.sendMessage(text, image: attachedImage)
	}
	
	func messageDidSent() {
		attachedImage = nil
		controller.hideHUD()
		startTimer()
		updateMessages()
	}
	
	func sendingEndedWithError(_ error: Error) {
		controller.hideHUD()
		controller.showAlert(with: R.string.twignatureError.messageWasNotDelivered())
	}
	
	private var updateInProgress = false
	
	fileprivate func updateMessages() {
		guard !updateInProgress else {
			return
		}
	
		interactor.loadNew(sinceId: messages.last?.id.nextId) { [weak self] result in
			self?.updateInProgress = false
			switch result {
			case .success(let messages):
				self?.updateWith(messagesToAdd: messages)
			case .failure(let error):
				self?.controller.showError(error)
			}
		}
	}
	
	private func updateWith(messagesToAdd: [Message]) {
		guard !messagesToAdd.isEmpty else {
			return
		}
		guard !messages.isEmpty else {
			messages = messagesToAdd.sorted(by: { $0.0.createdAt < $0.1.createdAt })
			controller.setChatDataSource(self, triggeringUpdateType: .firstLoad)
			return
		}
		
		messages.append(contentsOf: messagesToAdd)
		let uniqueMessages = Set(messages.map { $0 })
		messages = uniqueMessages.map({ $0 }).sorted(by: { $0.0.createdAt < $0.1.createdAt })
		controller.setChatDataSource(self, triggeringUpdateType: .reload)
	}
	
	//MARK: - ChatDataSourceProtocol
	weak var delegate: ChatDataSourceDelegateProtocol?
}

extension ConversationPresenter: ChatDataSourceProtocol {
	var hasMoreNext: Bool { return false }
	var hasMorePrevious: Bool { return false }
	var chatItems: [ChatItemProtocol] {
		var items = [ChatItemProtocol] ()
		for message in messages {
			if let mediaItem = MediaChatItemModel(message: message) {
				items.append(mediaItem)
			}
			if !message.textWithoutMediaLinks.characters.isEmpty {
				items.append(TNChatItem(message: message))
			}
		}
		return items
	}
	
	func loadNext() {}
	
	func loadPrevious() {}
	
	func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion:(_ didAdjust: Bool) -> Void) {
		completion(true)
	}
}

extension ConversationPresenter: ImagePickerDelegate {
	func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
		
	}
	
	func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
		imagePicker.dismiss(animated: true, completion: nil)
		attachedImage = images.first
		controller.setMessageImage(attachedImage)
	}
	
	func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
		
		imagePicker.dismiss(animated: true, completion: nil)
		attachedImage = nil
		controller.setMessageImage(attachedImage)
	}
}
