//
//  ChatsPresenter.swift
//  Twignature
//
//  Created by Anton Muratov on 9/14/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

private let chatsListRefreshInterval: TimeInterval = 70

class ChatsPresenter {
    private var chats: [Conversation] = []
    private var viewModel: ChatsViewModel!
    
    fileprivate let coordinator: ChatsCoordinator
    fileprivate unowned var controller: ChatsViewController
    fileprivate var interactor: ChatsInteractor
    
    // MARK: - Init
    
    required init(controller: ChatsViewController,
                  interactor: ChatsInteractor,
                  coordinator: ChatsCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
    }
    
    // MARK: - View events handling
    
    func viewIsReady() {
		loadChats()
    }
	
	func viewWillAppear() {
		loadChats()
		startTimer()
	}
	
	func viewWillDisapear() {
		stopTimer()
	}
    
    func handleCreateChat() {
        coordinator.showDirectMessagesUserPicker(tweetToShare: nil)
    }
    
    func cellTap(at index: Int) {
        let conversation = chats[index]
        coordinator.showChat(for: conversation, initialMessage: nil)
    }
    
    // MARK: - Private
    
	private var timer: Timer?
	
	private func startTimer() {
		stopTimer()
		timer = Timer.scheduledTimer(timeInterval: chatsListRefreshInterval,
		                             target: self,
		                             selector: #selector(runTimedCode),
		                             userInfo: nil, repeats: true)
	}
	
	dynamic
	private func runTimedCode() {
		loadChats()
	}
	
	private func stopTimer() {
		timer?.invalidate()
		timer = nil
	}
	
	private func loadChats() {
		interactor.loadChats { [weak self] (chatsResponse) in
			switch chatsResponse {
			case .success(let chats):
				self?.chats = chats
				let viewModel = ChatsViewModel(chats)
				self?.viewModel = viewModel
				self?.controller.setup(with: viewModel)
			case .failure(let error):
				print(error.localizedDescription)
			}
		}
	}
}
